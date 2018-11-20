close all;
clear all;
 
% video_set = {'1_1_01'};
seqs = configSeqs100;
% seqs = seqs([50]);
trks = configTrackers_exp;
% trks = trks([1 12 13]);
pathSave = '.\tmp\rd3_centererror_cmp_deep\';
if ~exist(pathSave,'dir');
    mkdir(pathSave);
end

plotSetting;

lenTotalSeq = 0;
resultsAll=[];
trackerNames=[];
 
% method_set = {'LCT'};
line_style = {'-g','b','-r','m','y','k'};
 
% gt_path = 'F:\task\DeepSea\fanfan\';%'F:\caffe-master\tracker_benchmark_v1.0\anno\';%'F:\caffe-master\Data\';
gt_path = 'F:\caffe-master\tracker_benchmark_v1.0\anno\';
results_path = 'F:\caffe-master\tracker_benchmark_v1.0\results\results_OPE_CVPR13\';


precision{length(seqs), length(trks)} = 0;
 
% auc_table{numel(video_set)+1, numel(method_set)+1} = 0;
% auc_table{1,1}=0;
% figure('Name', 'Pixel Error', 'Color', 'w');
for i = 1:length(seqs)
	s = seqs{i};
    % auc_table{i+1,1}=video_set{i};
    % read groundtruth
    varlist = {'gt','gt_center','gt_rect','gt_area','center','boxes,res_rect','res_area',...
        'overlap_rect','overlap_area','overlap_rate','mask','pixel_error','er'};
    clear(varlist{:});
	
    gt_file = fopen([gt_path s.name '.txt']); %[gt_path video_set{i} '\groundtruth_rect.txt']);
	
% 	gt_file = dlmread([gt_path s.name '.txt']);
	
    try
        groundtruth_roi = textscan(gt_file, '%f,%f,%f,%f', 'ReturnOnError', false);
        gt(:,1)=groundtruth_roi{1};
        gt(:,2)=groundtruth_roi{2};
        gt(:,3)=groundtruth_roi{3};
        gt(:,4)=groundtruth_roi{4};
    catch  %#ok, try different format (no commas)
        frewind(gt_file);
        groundtruth_roi = textscan(gt_file, '%f %f %f %f');
        gt(:,1)=groundtruth_roi{1};
        gt(:,2)=groundtruth_roi{2};
        gt(:,3)=groundtruth_roi{3};
        gt(:,4)=groundtruth_roi{4};
    end
    gt_center(:,1) = gt(:,1) + gt(:,3)/2;
    gt_center(:,2) = gt(:,2) + gt(:,4)/2;
    gt_rect(:,1) = gt(:,1);
    gt_rect(:,2) = gt(:,2);
    gt_rect(:,3) = gt(:,1) + gt(:,3);
    gt_rect(:,4) = gt(:,2) + gt(:,4);
    gt_area = gt(:,3).*gt(:,4);
    % caculate different method precision
    for index_trks = 1:length(trks)
%         auc_table{1,ii+1}=trks{ii}.name;
        clear('fig','boxes','center','er','pixel_error','res_rect','overlap_rect','mask',...
            'overlap_rate','overlap_area','xx','yy');
        %read results (标准格式)
%         fileName = [pathRes seq_name '_' name '.mat'];
        r = load([results_path seqs{i}.name '_' trks{index_trks}.name '.mat']);
        boxes = r.results{1}.res;
        if size(boxes,1) ~= size(gt,1)
            boxes = boxes(1:size(gt,1),:);
        end
        % caculate pixel error
        center(:,1) = boxes(:,1) + boxes(:,3)/2;
        center(:,2) = boxes(:,2) + boxes(:,4)/2;
        er = center - gt_center;
        pixel_error = sqrt(er(:,1).*er(:,1)+er(:,2).*er(:,2));
        % caculate overlaprate
        res_rect(:,1) = boxes(:,1);
        res_rect(:,2) = boxes(:,2);
        res_rect(:,3) = boxes(:,1)+boxes(:,3);
        res_rect(:,4) = boxes(:,2)+boxes(:,4);
        res_area = boxes(:,3).*boxes(:,4);
        overlap_rect(:,1) = max(res_rect(:,1), gt_rect(:,1));
        overlap_rect(:,2) = max(res_rect(:,2), gt_rect(:,2));
        overlap_rect(:,3) = min(res_rect(:,3), gt_rect(:,3));
        overlap_rect(:,4) = min(res_rect(:,4), gt_rect(:,4));
        mask = or((overlap_rect(:,1)>overlap_rect(:,3)), overlap_rect(:,2)>overlap_rect(:,4));
        overlap_area = (overlap_rect(:,3)-overlap_rect(:,1)).*(overlap_rect(:,4)-overlap_rect(:,2));
        overlap_area(mask) = 0;
        overlap_rate = overlap_area ./ (gt_area + res_area - overlap_area + eps);
        % visualization and result
        fig.video = seqs{i}.name;
        fig.method = trks{index_trks}.name;
        fig.len = size(boxes,1);
        [yy, xx] = cdfcc(overlap_rate);
        fig.ol = overlap_rate;
        fig.olm = mean(overlap_rate);
        fig.olcdf.x = xx;
        fig.olcdf.x(1) = 0;
        fig.olcdf.x(end) = 1;
        fig.olcdf.y = 1-yy;
        [yy, xx] = cdfcc(pixel_error);
        fig.pe = pixel_error;
        fig.pem = mean(pixel_error);
        fig.pecdf.x = xx;
        fig.pecdf.y = yy;
        precision{i,index_trks} = fig;
     end
    
    % show plot
    if 1,
        figure('Name', 'Pixel Error', 'Color', 'w');
        for index_trks = 1:numel(trks),
            len = precision{i,index_trks}.len;
            pe = precision{i,index_trks}.pe;
            plot(1:1300, pe(1:1300), line_style{index_trks}, 'LineWidth', 2), hold on;
            trks_name = trks{index_trks}.name;
            trks_name = strrep(trks_name,'_','\_');
%             if strcmp(trks_name,'STAPLE_CA'),
%                 trks_name = strcat(trks_name(1:6),'\',trks_name(7:9));
%             end
%             if strcmp(trks_name,'LHCF_CA'),
%                 trks_name = strcat(trks_name(1:4),'\',trks_name(5:7));
%             end
            lg{index_trks} = [trks_name ': ' sprintf('%.2f', precision{i,index_trks}.pem)];
        end
        seq_name = seqs{i}.name;
%         seq_name = strcat(seq_name(1),'\',  seq_name(2:3),'\',seq_name(4:6));
        title(seq_name);xlabel('Frame');ylabel('Pixel Error');
        legend(lg);
%         imwrite(frame2im(getframe(gcf)), [pathSave  num2str(i) '.png']);
            
    end
    if length(trks)==1,
        imwrite(frame2im(getframe(gcf)), [pathSave  seqs{i}.name '_' trks{index_trks}.name '.png']);
    else
        imwrite(frame2im(getframe(gcf)), [pathSave  seqs{i}.name '_' 'all' '.png']);
    end
end