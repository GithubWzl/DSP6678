function [data_board_div_valid,board_para]=board_div(data_board_div,targets_outlier)
%targets_little_board相比子区划分表去除掉了野值
%little_board_para大小为子区数量*3，第一列为子区编号，第二列为子区中有效的靶标数量

cnt=length(data_board_div);

board_cnt=0;

temp=-9999;%遍历子板分区表，找出共有多少个子区
for i=1:cnt
    if temp~=data_board_div(i,1)
        board_cnt=board_cnt+1;
    end
    temp=data_board_div(i,1);
end

board_para=zeros(board_cnt,2);%分配存储空间

data_board_div_1=data_board_div;

j=1;%将起始编号放在第一个靶标
temp=data_board_div(1,1);
board_para(1,1)=data_board_div(1,1);%将起始编号放在第一个子区
for i=1:cnt
    if targets_outlier(data_board_div_1(i,2))%判断某一行的靶标是否为野值
        data_board_div_1(i,2)=0;%是野值的话，设置该靶标编号为0，表示无效
    else
        data_board_div_1(i,2)=1;%否则设置为1
    end
    
    if data_board_div_1(i,1)~=temp%与上一行的子区编号做比较，若不同，则记录子区信息的矩阵切换到下一行，记录本行的子区编号
        j=j+1;
        board_para(j,1)=data_board_div_1(i,1);
    end
    
    board_para(j,2)=board_para(j,2)+data_board_div_1(i,2);%累加子区的有效靶标数
    
    temp=data_board_div_1(i,1);
end

data_board_div_valid=zeros(sum(data_board_div_1(:,2)),2);%分配存储空间

j=1;
for i=1:cnt%用于剔除无效的靶标
    if data_board_div_1(i,2)==1
        data_board_div_valid(j,:)=data_board_div(i,:);
        j=j+1;
    end
end

end



