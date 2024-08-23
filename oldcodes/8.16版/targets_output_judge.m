function [board_belong,targets_output_xy] = targets_output_judge(targets_output_XY,board_coordinate_para)

board_belong=zeros(length(targets_output_XY),1);   %属于哪个小子板

targets_output_xy=zeros(length(targets_output_XY),2);  %局部坐标系坐标

%物理子板划线分界坐标
border_x=[3.5,6.5,9.5,12.5,15.5];   
border_y=[2.5,4.5];

count_x=0;  %第几列
count_y=0;  %第几行
%   此处显示详细说明
    for i=1:length(targets_output_XY)    %循环遍历每个目标输出点
        
        for j=1:length(border_x)   %判断目标输出点的X范围
            if targets_output_XY(i,1)<border_x(j)
                count_x=j;
                break
            end
        end
        
        for k=1:length(border_y)     %判断目标输出点的Y范围
            if targets_output_XY(i,2)<border_y(k)
                count_y=k;
                break
            end
        end
        
     big_board_belong=count_x + (count_y-1)*length(border_x);    %判断在哪个物理子板上
     
     board_1=2*big_board_belong-1;        %物理子板第一个小子板编号
     board_2=2*big_board_belong;        %物理子板第二个小子板编号
     
     %目标输出点到第一个小子板原点距离平方
     if(board_coordinate_para(board_1,:)==[0,0,0,0])
         D_1=999999;
     else
         D_1=(targets_output_XY(i,1)-board_coordinate_para(board_1,1))^2 +(targets_output_XY(i,2)-board_coordinate_para(board_1,2))^2;
     end
     
     %目标输出点到第二个小子板原点距离平方
     if(board_coordinate_para(board_2,:)==[0,0,0,0])
         D_2=999999;
     else
         D_2=(targets_output_XY(i,1)-board_coordinate_para(board_2,1))^2 +(targets_output_XY(i,2)-board_coordinate_para(board_2,2))^2;
     end
     
     if D_1<D_2
        board_belong(i)= board_1;      %属于哪个小子板
        
        %目标输出点相对于这个小子板的局部坐标
        targets_output_xy(i,1)=targets_output_XY(i,1)-board_coordinate_para(board_1,1);
        targets_output_xy(i,2)=targets_output_XY(i,2)-board_coordinate_para(board_1,2);
     else
        board_belong(i)= board_2;
        targets_output_xy(i,1)=targets_output_XY(i,1)-board_coordinate_para(board_2,1);
        targets_output_xy(i,2)=targets_output_XY(i,2)-board_coordinate_para(board_2,2);
     end 
    end
end

