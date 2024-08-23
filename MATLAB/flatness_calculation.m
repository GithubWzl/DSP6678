function [board_flatness_pt1,board_flatness_pt2,board_flatness_pt1_avg,board_flatness_pt2_avg]=flatness_calculation(data_board_div_valid,board_para,targets_xy,targets_Delta_pt1nk,targets_Delta_pt2nk,targets_XY,board_o,targets_outlier)
%输出两个参考面下的平面度参数和平均平面度

board_cnt=length(board_para);

board_flatness_pt1=zeros(board_cnt,3);%平面度参数3列，是每个子板相对于指向单元1的平面度参数
board_flatness_pt2=zeros(board_cnt,3);%平面度参数3列，是每个子板相对于指向单元2的平面度参数
board_flatness_pt1_avg=zeros(board_cnt,3);%平均平面度参数，相对于pt1，其中前两列每一行都存储同样的φ和θ，第三列存储每个子板对应的δ0n
board_flatness_pt2_avg=zeros(board_cnt,3);%平均平面度参数，相对于pt2，其中前两列每一行都存储同样的φ和θ，第三列存储每个子板对应的δ0n

boards_ID=board_para(:,1);%分解出子区和靶标的编号
targets_ID=data_board_div_valid(:,2);

start_target=1;%设定起始靶标编号，每轮循环后会更新此值到下一个子区的起始位置
for i=1:board_cnt
    targets_board_cnt=board_para(i,2);%确定子区上靶标数量
    if targets_board_cnt<3%若靶标数量不足，则不参与平面度参数计算
        board_flatness_pt1(i,:)=nan;
        board_flatness_pt2(i,:)=nan;
    else
        range_targets_ID=targets_ID(start_target:start_target+board_para(i,2)-1);%确定该子区上全部靶标的编号
        range_Delta_pt1=targets_Delta_pt1nk(range_targets_ID,:);%获取子区上全部靶标的Delta值
        range_Delta_pt2=targets_Delta_pt2nk(range_targets_ID,:);
        
        range_targets_xy=targets_xy(start_target:start_target+targets_board_cnt-1,:);%获取子区上全部靶标的局部坐标
        A=[range_targets_xy(:,2),-range_targets_xy(:,1),ones(targets_board_cnt,1)];%构造矩阵A
        
        board_flatness_pt1(i,:)=(((A'*A)\A')*range_Delta_pt1)';%计算子区的平面度
        board_flatness_pt2(i,:)=(((A'*A)\A')*range_Delta_pt2)';
    end
    start_target=start_target+targets_board_cnt;%更新此值到下一个子区的起始位置
end

targets_valid_ID=find(targets_outlier==0);%找出非野值的靶标编号

OXY_O=0.5*max(targets_XY)+0.5*min(targets_XY);%将OXY坐标搬移到以所有靶标的中心为原点
targets_XY_1=targets_XY-OXY_O;
targets_XY_2=targets_XY_1(targets_valid_ID,:);%剔除野值所在靶标

Delta_pt1=targets_Delta_pt1nk(targets_valid_ID,:);%剔除野值
Delta_pt2=targets_Delta_pt2nk(targets_valid_ID,:);

E=[targets_XY_2(:,2),-targets_XY_2(:,1),ones(length(targets_XY_2),1)];%构造矩阵E

temp_para1=((E'*E)\E')*Delta_pt1;%计算平均平面度
temp_para2=((E'*E)\E')*Delta_pt2;

fai_pt1=temp_para1(1);xita_pt1=temp_para1(2);delta0_pt1=temp_para1(3);%分解出3个参数
fai_pt2=temp_para2(1);xita_pt2=temp_para2(2);delta0_pt2=temp_para2(3);

board_flatness_pt1_avg(:,1:2)=[fai_pt1*ones(board_cnt,1),xita_pt1*ones(board_cnt,1)];%输出平均平面度参数的φ和θ
board_flatness_pt2_avg(:,1:2)=[fai_pt2*ones(board_cnt,1),xita_pt2*ones(board_cnt,1)];

for i=1:board_cnt%输出平均平面度参数的δ0n
    board_flatness_pt1_avg(i,3)=fai_pt1*board_o(i,2)-xita_pt1*board_o(i,1)+delta0_pt1;
    board_flatness_pt2_avg(i,3)=fai_pt2*board_o(i,2)-xita_pt2*board_o(i,1)+delta0_pt2;
end

end

