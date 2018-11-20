clf
a = [0.3 0.4 0.5 0.6]; % update
b = [0.4 0.5 0.6 0.7]; % accept
c = [0.15 0.2 0.25 0.3]; % activate

d = [1 2 2 5
     13 11 23 34
     11 12 20 15
     11 12 20 15
    
    60 65 65 64
    75 77 78 76
    60 65 65 64
    40 45 49 53
    
    70 76 76 73
    81 82 90 86
    75 73 70 74
    60 67 68 66 
    
    30 34 38 40
    35 38 41 42
    35 1 10 1
    15 16 10 1];

% d = exp(d)/sum(exp(d(:)))
index = 1;
 
for i = 1:4
    for j = 1:4
        for k = 1:4
%             10 * d(index)
            scatter3(a(i),b(j),c(k),40,d(index),'fill');
            index = index + 1;
            hold on
        end
    end
end
% text(a(3),b(2),c(3),'0.871');
grid on
caxis([0 100])
xlabel('T_u_p_d_a_t_e')
ylabel('T_r_d')
zlabel('T_s_c_a_l_e')
colorbar

