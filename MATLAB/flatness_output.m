function [delta_pt1_output,delta_pt2_output,delta_abs_output,global_flatness_pt1,global_flatness_pt2,abs_flatness]=flatness_output(board_para,targets_output_xy,board_belong,board_flatness_pt1,board_flatness_pt2,board_flatness_pt1_avg,board_flatness_pt2_avg,targets_Delta_pt1nk,targets_Delta_pt2nk,data_board_div)

cnt_output=length(targets_output_xy);%提取目标输出点个数

delta_pt1_output=zeros(cnt_output,1);%分配存储空间
delta_pt2_output=zeros(cnt_output,1);
delta_abs_output=zeros(cnt_output,1);

board_flatness_para_pt1=board_flatness_pt1-board_flatness_pt1_avg;%减去整体偏移（平均平面度）
board_flatness_para_pt2=board_flatness_pt2-board_flatness_pt2_avg;
board_flatness_para_abs=(board_flatness_pt1+board_flatness_pt2)/2;%计算绝对平面度（不一定用这个公式，待定）

for i=1:cnt_output%循环目标输出点横坐标数量次数，即循环目标输出点数量次数
    board_belong_ThisTime=board_belong(i);%当前目标输出点所属子板
    board_index=find(board_para(:,1)==board_belong_ThisTime);
    if board_para(board_index,2)==0%按逻辑，不会出现属于无效子区的情况
        delta_pt1_output(i)=nan;
        delta_pt2_output(i)=nan; 
        delta_abs_output(i)=nan; 
        fprintf('目标输出点%d所在子区无效，无法计算结果\n',i);
    elseif board_para(board_index,2)<3%子区只有1个或2个靶标的情况，直接取靶标的Delta值平均值作为目标输出点的读数
        targets_ID_index=find(data_board_div(:,1)==board_belong_ThisTime);
        targets_ID=data_board_div(targets_ID_index,2);
        delta_pt1_output(i)=0.5*max(targets_Delta_pt1nk(targets_ID))+0.5*min(targets_Delta_pt1nk(targets_ID));
        delta_pt2_output(i)=0.5*max(targets_Delta_pt2nk(targets_ID))+0.5*min(targets_Delta_pt2nk(targets_ID));
        delta_abs_output(i)=nan;
        fprintf('目标输出点%d所在子区仅有%d个有效靶标，采用特殊计算方法\n',i,length(targets_ID));
    else%正常计算
        delta_pt1_output(i)=board_flatness_para_pt1(board_index,1)*targets_output_xy(i,2) - board_flatness_para_pt1(board_index,2)*targets_output_xy(i,1) + board_flatness_para_pt1(board_index,3);
        delta_pt2_output(i)=board_flatness_para_pt2(board_index,1)*targets_output_xy(i,2) - board_flatness_para_pt2(board_index,2)*targets_output_xy(i,1) + board_flatness_para_pt2(board_index,3);
        delta_abs_output(i)=board_flatness_para_abs(board_index,1)*targets_output_xy(i,2) - board_flatness_para_abs(board_index,2)*targets_output_xy(i,1) + board_flatness_para_abs(board_index,3);
    end
    %计算输出点计算与两个参考面的距离
end

nonNaNCount = sum(~isnan(delta_pt1_output));%判断目标输出点个数，太少的话发出警告
if nonNaNCount<3
    fprintf('警告！有效目标输出点个数过少\n');
end

%计算整体平面度
global_flatness_pt1 = max(delta_pt1_output)-min(delta_pt1_output);
global_flatness_pt2 = max(delta_pt2_output)-min(delta_pt2_output);
abs_flatness = max(delta_abs_output)-min(delta_abs_output);

end