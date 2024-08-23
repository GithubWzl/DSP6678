function [targets_xy,board_o]=xy_calculation(data_board_div_valid,targets_XY,board_para)
%targets_xy大小为data_board_div_valid长度*2
%board_o代表局部坐标系原点位置，大小为子区数量*2，两列为坐标原点坐标

targets_xy=zeros(length(data_board_div_valid),2);%分配存储空间
board_o=zeros(length(board_para),2);

boards_ID=board_para(:,1);%提取子区和靶标的编号
targets_ID=data_board_div_valid(:,2);

start_target=1;%设定起始靶标编号，每轮循环后会更新此值到下一个子区的起始位置

for i=1:length(board_para)
    if board_para(i,2)==0
        fprintf('编号为%d的子区无效\n',boards_ID(i));
        board_o(i,:)=nan;
    else
        range_targets_ID=targets_ID(start_target:start_target+board_para(i,2)-1);%确定该子区上全部靶标的编号
        range_targets_XY=targets_XY(range_targets_ID,:);%获取子区上全部靶标的坐标
        max_temp=max(range_targets_XY);
        min_temp=min(range_targets_XY);
        board_o(i,:)=0.5*max_temp+0.5*min_temp;%计算局部坐标系原点和局部坐标系上靶标坐标，1、2、3、4及以上靶标数的计算方法均可兼容此公式
        targets_xy(start_target:start_target+board_para(i,2)-1,:)=range_targets_XY-board_o(i,:);
        if board_para(i,2)<3
            fprintf('编号为%d的子区只有1或2个靶标有效，不参与平面度计算\n',boards_ID(i));
        end
    end
    start_target=start_target+board_para(i,2);%更新此值到下一个子区的起始位置
end

end