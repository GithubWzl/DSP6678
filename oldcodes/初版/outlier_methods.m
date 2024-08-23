function board_methods=outlier_methods(targets_outlier,board_cnt)

%0：4个点确定一个小子板
%1：单个小子板三点确定一个平面
%2：两个小子板均三点确定一个平面
%3：不划分小子板，4个点确定一个平面
%4：不划分小子板，3个点确定一个平面
%5：插值

targets_per_board=length(targets_outlier)/board_cnt;

board_methods=zeros(board_cnt,1);

for m=1:board_cnt
    targets6=targets_outlier((m-1)*targets_per_board+1:m*targets_per_board);
    outlier_cnt=sum(targets6);
    switch outlier_cnt
        case 0
            board_methods(m,1)=0;
        case 1
            if (targets6(3)+targets6(4))==0
                board_methods(m,1)=1;
            else
                board_methods(m,1)=2;
            end
        case 2
            if (targets6(1)+targets6(2))==1 && (targets6(5)+targets6(6))==1
                board_methods(m,1)=2;
            else
                board_methods(m,1)=3;
            end
        case 3
            if (targets6(1)+targets6(3)+targets6(5))==3 || (targets6(2)+targets6(4)+targets6(6))==3
                board_methods(m,1)=5;
            else
                board_methods(m,1)=4;
            end
        otherwise
            board_methods(m,1)=5;
    end
end

end