function [targets_little_board,little_board_valid]=board_div(board_methods,targets_outlier,targets_xy)

targets_cnt=length(targets_outlier);
board_cnt=length(board_methods);

%a(a==0)=8;a(a==1)=7;a(a==2)=6;a(a==3)=5;a(a==4)=4;a(a==5)=2;
%a=8-board_methods;a(a==3)=2;
%b=sum(a);

little_board_valid=zeros(board_cnt*2,1);

little_board_ID=zeros(board_cnt*8,1);
targets_ID=zeros(board_cnt*8,1);
xy=zeros(board_cnt*8,2);
targets_valid=zeros(board_cnt*8,1);

for m=1:board_cnt
    little_board_ID(8*m-7)=2*m-1;little_board_ID(8*m-3)=2*m;
    little_board_ID(8*m-6)=2*m-1;little_board_ID(8*m-2)=2*m;
    little_board_ID(8*m-5)=2*m-1;little_board_ID(8*m-1)=2*m;
    little_board_ID(8*m-4)=2*m-1;little_board_ID(8*m-0)=2*m;
    targets_ID(8*m-7)=6*m-5;targets_ID(8*m-3)=6*m-3;
    targets_ID(8*m-6)=6*m-4;targets_ID(8*m-2)=6*m-2;
    targets_ID(8*m-5)=6*m-3;targets_ID(8*m-1)=6*m-1;
    targets_ID(8*m-4)=6*m-2;targets_ID(8*m-0)=6*m-0;
    %在这里预留出修改坐标的位置
    xy(8*m-7,1:2)=targets_xy(6*m-5,1:2);
    xy(8*m-6,1:2)=targets_xy(6*m-4,1:2);
    xy(8*m-5,1:2)=targets_xy(6*m-3,1:2);
    xy(8*m-4,1:2)=targets_xy(6*m-2,1:2);
    xy(8*m-3,1:2)=targets_xy(6*m-3,1:2);
    xy(8*m-2,1:2)=targets_xy(6*m-2,1:2);
    xy(8*m-1,1:2)=targets_xy(6*m-1,1:2);
    xy(8*m-0,1:2)=targets_xy(6*m-0,1:2);
    targets_valid(8*m-7)=1-targets_outlier(6*m-5);
    targets_valid(8*m-6)=1-targets_outlier(6*m-4);
    targets_valid(8*m-5)=1-targets_outlier(6*m-3);
    targets_valid(8*m-4)=1-targets_outlier(6*m-2);
    targets_valid(8*m-3)=1-targets_outlier(6*m-3);
    targets_valid(8*m-2)=1-targets_outlier(6*m-2);
    targets_valid(8*m-1)=1-targets_outlier(6*m-1);
    targets_valid(8*m-0)=1-targets_outlier(6*m-0);
    
    switch board_methods(m)
        case 0%4个点确定一个小子板
            little_board_valid(2*m-1)=1; little_board_valid(2*m)=1;
        case 1%单个小子板三点确定一个平面
            little_board_valid(2*m-1)=1; little_board_valid(2*m)=1;
        case 2%两个小子板均三点确定一个平面
            little_board_valid(2*m-1)=1; little_board_valid(2*m)=1;
        case 3%不划分小子板，4个点确定一个平面
            little_board_valid(2*m-1)=1; little_board_valid(2*m)=0;
        case 4%不划分小子板，3个点确定一个平面
            little_board_valid(2*m-1)=1; little_board_valid(2*m)=0;
        case 5%插值
            little_board_valid(2*m-1)=0; little_board_valid(2*m)=0;
        otherwise
            error('错误，未知野值情况')
    end
end

targets_little_board=zeros(board_cnt*8,5);
targets_little_board(:,1)=little_board_ID;
targets_little_board(:,2)=targets_ID;
targets_little_board(:,3:4)=xy;
targets_little_board(:,5)=targets_valid;

end