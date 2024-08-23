function [targets_xy,board_coordinate_para]=xy_calculation(targets_little_board,targets_XY,little_board_valid,board_cnt,targets_per_board)

targets_xy=zeros(board_cnt*targets_per_board,2);
board_coordinate_para=zeros(board_cnt,4);

targets_ID=targets_little_board(:,2);

max_temp=zeros(1,2);
min_temp=zeros(1,2);

for i=1:board_cnt
    if little_board_valid(i)==0
        continue
    else
        temp4=targets_XY(targets_ID((i-1)*targets_per_board+1:i*targets_per_board),:);
        temp_vaild=targets_little_board((i-1)*targets_per_board+1:i*targets_per_board,3);
        max_temp(1)=max(temp4(find(temp_vaild),1));
        max_temp(2)=max(temp4(find(temp_vaild),2));
        min_temp(1)=min(temp4(find(temp_vaild),1));
        min_temp(2)=min(temp4(find(temp_vaild),2));
        board_coordinate_para(i,1:2)=(max_temp+min_temp)/2;
        board_coordinate_para(i,3:4)=max_temp-min_temp;
        targets_xy((i-1)*targets_per_board+1:i*targets_per_board,:)=temp4-board_coordinate_para(i,1:2);
    end
end

end