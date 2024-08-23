function [delta_pt1_output,delta_pt2_output,delta_abs_output,global_flatness_pt1,global_flatness_pt2,abs_flatness]=flatness_output(little_board_valid,targets_output_xy,board_belong,board_para_pt1,board_para_pt2,board_para_pt1_avg,board_para_pt2_avg)
board_para_deltapt1 = board_para_pt1 - board_para_pt1_avg;
board_para_deltapt2 = board_para_pt2 - board_para_pt2_avg;
board_para_abs=(board_para_pt1+board_para_pt2)/2;

delta_pt1_output = zeros(length(targets_output_xy(:,1)),1);
delta_pt2_output = zeros(length(targets_output_xy(:,1)),1);
delta_abs_output = zeros(length(targets_output_xy(:,1)),1);
for i =1:length(targets_output_xy(:,1))%循环目标输出点横坐标数量次数，即循环目标输出点数量次数
    board_belong_ThisTime = board_belong(i);%当前目标输出点所属子板
    if little_board_valid(board_belong_ThisTime) == 0
        delta_pt1_output(i,1) = nan;
        delta_pt2_output(i,1) = nan; 
        delta_abs_output(i,1) = nan; 
        fprintf('目标输出点%d所在物理子板%d无效，该点计算结果也无效\n',i,floor((board_belong_ThisTime+1)/2));%这里需要一点解析，若此物理子板上的两个子区均无效，才会出现该判定。因为根据模块targets_output_judge的逻辑，若只有一个子区无效，无效子区的坐标原点会在（0,0），则该目标输出点一定会被判定到有效的子区上。
    else
        delta_pt1_output(i,1) = board_para_deltapt1(board_belong_ThisTime,1)*targets_output_xy(i,2) - board_para_deltapt1(board_belong_ThisTime,2)*targets_output_xy(i,1) + board_para_deltapt1(board_belong_ThisTime,3);
        delta_pt2_output(i,1) = board_para_deltapt2(board_belong_ThisTime,1)*targets_output_xy(i,2) - board_para_deltapt2(board_belong_ThisTime,2)*targets_output_xy(i,1) + board_para_deltapt2(board_belong_ThisTime,3);
        delta_abs_output(i,1) = board_para_abs(board_belong_ThisTime,1)*targets_output_xy(i,2) - board_para_abs(board_belong_ThisTime,2)*targets_output_xy(i,1) + board_para_abs(board_belong_ThisTime,3);
    end
    %计算输出点计算与两个参考面的距离
end
nonNaNCount = sum(~isnan(delta_pt1_output));%判断目标输出点横坐标数量数量
if nonNaNCount<10
    error('The number of outputtargets is too small.')
end
%计算整体平面度
global_flatness_pt1 = max(delta_pt1_output) - min(delta_pt1_output);
global_flatness_pt2 = max(delta_pt2_output) - min(delta_pt2_output);
abs_flatness = max(delta_abs_output) - min(delta_abs_output);

end