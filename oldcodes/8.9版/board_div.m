function [targets_little_board,little_board_valid]=outlier_methods(targets_outlier,board_cnt,targets_per_board,targets_per_phy_board)

targets_cnt_little_board=board_cnt*targets_per_board;
targets_cnt=board_cnt*targets_per_phy_board/2;

little_board_ID=zeros(targets_cnt_little_board,1);
targets_ID=zeros(targets_cnt_little_board,1);
targets_valid=zeros(targets_cnt_little_board,1);
little_board_valid=zeros(board_cnt,1);


for m=1:board_cnt/2
    for n=1:targets_per_board
        little_board_ID(targets_per_board*2*(m-1)+n)=2*m-1;
        little_board_ID(targets_per_board*2*(m-0.5)+n)=2*m;
        targets_ID(targets_per_board*2*(m-1)+n)=targets_per_phy_board*(m-1)+n;
        targets_ID(targets_per_board*2*(m-0.5)+n)=targets_per_phy_board*(m-1)+(targets_per_phy_board-targets_per_board)+n;
        targets_valid(targets_per_board*2*(m-1)+n)=1-targets_outlier(targets_ID(targets_per_board*2*(m-1)+n));
        targets_valid(targets_per_board*2*(m-0.5)+n)=1-targets_outlier(targets_ID(targets_per_board*2*(m-0.5)+n));
    end
    targets6=targets_outlier((m-1)*targets_per_board*1.5+1:m*targets_per_board*1.5);
    if targets6(1)+targets6(2)+targets6(3)+targets6(4)==0
        little_board_valid(2*m-1)=1;
    elseif targets6(1)+targets6(2)+targets6(3)+targets6(4)==1
        little_board_valid(2*m-1)=1;
    else
        little_board_valid(2*m-1)=0;
        fprintf('子区%d野值过多，无效\n',2*m-1);
    end
    if targets6(3)+targets6(4)+targets6(5)+targets6(6)==0
        little_board_valid(2*m)=1;
    elseif targets6(3)+targets6(4)+targets6(5)+targets6(6)==1
        little_board_valid(2*m)=1;
    else
        little_board_valid(2*m)=0;
        fprintf('子区%d野值过多，无效\n',2*m);
    end
end

targets_little_board=zeros(targets_cnt_little_board,3);
targets_little_board(:,1)=little_board_ID;
targets_little_board(:,2)=targets_ID;
targets_little_board(:,3)=targets_valid;

end



