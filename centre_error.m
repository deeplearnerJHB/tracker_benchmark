close all;
clear all;
 
% video_set = {'1_1_01'};
seqs = fishSeqs;
trks = configTrackers;


plotSetting;

lenTotalSeq = 0;
resultsAll=[];
trackerNames=[];
 
% method_set = {'LCT'};
% line_style = {'--r', '--g'};
 
% gt_path = 'F:\task\DeepSea\fanfan\';%'F:\caffe-master\tracker_benchmark_v1.0\anno\';%'F:\caffe-master\Data\';
gt_path = 'F:\caffe-master\tracker_benchmark_v1.0\anno\';
results_path = 'F:\caffe-master\tracker_benchmark_v1.0\results\res-fish-mat\';
% 'F:\caffe-master\tracker_benchmark_v1.0\results\results_OPE_challenge\';


precision{numel(seqs), numel(trks)} = 0;
 
% auc_table{numel(video_set)+1, numel(method_set)+1} = 0;
% auc_table{1,1}=0;
 
for i = 1:length(seqs)
	s = seqs{i};
    % auc_table{i+1,1}=video_set{i};
    % read groundtruth
    varlist = {'gt','gt_center','gt_rect','gt_area','center','boxes,res_rect','res_area',...
        'overlap_rect','overlap_area','overlap_rate','mask','pixel_error','er'};
    clear(varlist{:});
	
    % gt_file = fopen([gt_path video_set{i} '\groundtruth_rect.txt']);
	
	gt_file = dlmread([pathAnno s.name '.txt']);
	
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
    for ii = 1:numel(method_set)
        auc_table{1,ii+1}=method_set{ii};
        clear('fig','boxes','center','er','pixel_error','res_rect','overlap_rect','mask',...
            'overlap_rate','overlap_area','xx','yy');
        %read results (标准格式)
        r = load([results_path lower(video_set{i}) '_' method_set{ii} '.mat']);
        boxes = r.results{1}.res;
        assert(size(boxes,1)==size(gt,1));
        % caculate pixel error
        center(:,1) = boxes(:,1)+boxes(:,3)/2;
        center(:,2) = boxes(:,2)+boxes(:,4)/2;
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
        fig.video = video_set{i};
        fig.method = method_set{ii};
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
        precision{i,ii} = fig;
        auc_table{i+1,ii+1} = fig.olm;
    end
    
    % show plot
    if 1,
        figure('Name', 'Pixel Error', 'Color', 'w');
        for ii = 1:numel(method_set),
            plot(1:precision{i,ii}.len, precision{i,ii}.pe, line_style{ii}, 'LineWidth', 2), hold on;
            lg{ii} = [method_set{ii} ' ' sprintf('%.2f', precision{i,ii}.pem)];
        end
        title(video_set{i});xlabel('Frame#');ylabel('Pixel Error');
        legend(lg);
    end
end
   

   
%         figure('Name', 'Overlap Rate', 'Color', 'w');
%         for ii = 1:numel(method_set),
%             plot(1:precision{i,ii}.len, precision{i,ii}.ol, line_style{ii}, 'LineWidth', 2), hold on;
%             lg{ii} = [method_set{ii} ' ' sprintf('%.2f', precision{i,ii}.olm)];
%         end
%         title(video_set{i});xlabel('Frame#');ylabel('Overlap Rate');
%         legend(lg);
%         
%         figure('Name', 'Pixel Error Success Plot', 'Color', 'w');
%         for ii = 1:numel(method_set),
%             plot(precision{i,ii}.pecdf.x, precision{i,ii}.pecdf.y, line_style{ii}, 'LineWidth', 2), hold on;
%             %lg{ii} = [method_set{ii} ' ' sprintf('%.2f', trapz(precision{i,ii}.pecdf.x(2:end-1), precision{i,ii}.pecdf.y(2:end-1)))];
%         end
%         title(video_set{i});xlabel('Pixel Error Threshold');ylabel('Success Rate');
%         legend(method_set);
%         
%         figure('Name', 'Overlap Rate Success Plot', 'Color', 'w');
%         for ii = 1:numel(method_set),
%             plot(precision{i,ii}.olcdf.x, precision{i,ii}.olcdf.y, line_style{ii}, 'LineWidth', 2), hold on;
%             lg{ii} = [method_set{ii} ' ' sprintf('%.2f', trapz(precision{i,ii}.olcdf.x, precision{i,ii}.olcdf.y))];
%         end
%         title(video_set{i});xlabel('Overlap Rate Threshold');ylabel('Success Rate');
%         legend(lg);
%         
%     end
%     
% end