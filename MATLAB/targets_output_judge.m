function [board_belong,targets_output_xy] = targets_output_judge(targets_output_XY,data_board_div,board_para,board_o,targets_phy_belong,targets_output_phy_belong)

board_belong=zeros(length(targets_output_XY),1);%属于哪个子区
targets_output_xy=zeros(length(targets_output_XY),2);%局部坐标系坐标

phy_board_range=[targets_output_phy_belong;targets_phy_belong];

%if min(phy_board_range)<=0%判断格式是否正确
%    error('错误！物理子板的编号应从1开始，并尽量连续\n');
%end

cnt=length(data_board_div);
board_cnt=length(board_para);
output_cnt=length(targets_output_phy_belong);

board_phy_belong=zeros(board_cnt,1);

j=1;
temp=-9999;%设定一个不可能取到的靶标编号作为初始对比temp

for i=1:cnt%判定每个子区属于哪个物理子板，与board_para按行对齐
    if temp~=data_board_div(i,1)
        board_phy_belong(j)=targets_phy_belong(data_board_div(i,2));%以每个子区第一个靶标所属物理子板为准
        j=j+1;
    end
    temp=data_board_div(i,1);
end

for i=1:output_cnt%对每个目标输出点进行判断
    thistime_phy_ID=targets_output_phy_belong(i);%提取该点所属物理子板编号
    range_board=board_para(find(board_phy_belong==thistime_phy_ID),:);%提取出所有该物理子板包含的子区信息
    if isempty(range_board)%判定物理子板编号是否在范围之内
        error('错误！出现了不属于任何物理子板的目标输出点，编号%d\n',i);
    elseif sum(range_board(:,2))==0%判定物理子板上全部子区无效的情况
        fprintf('目标输出点%d所在物理子板找不到有效子区\n',i);
        board_belong(i)=nan;
        targets_output_xy(i,:)=nan;
    else
        range_board_o=board_o(find(board_phy_belong==thistime_phy_ID),:);%提取对应子区的局部坐标系原点位置
        range_targets_output_XY=targets_output_XY(i,:);%提取对应目标输出点坐标
        
        distance1=range_targets_output_XY-range_board_o;%计算目标输出点与每个原点的距离
        distance=distance1(:,1).^2+distance1(:,2).^2;
        
        [~,min_index]=min(distance);
        
        board_belong(i)=range_board(min_index,1);%输出
        targets_output_xy(i,:)=targets_output_XY(i,:)-range_board_o(min_index,:);
    end
    
end

end

