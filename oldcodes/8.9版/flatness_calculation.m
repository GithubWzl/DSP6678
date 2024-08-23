function [board_para_pt1,board_para_pt2,board_para_pt1_avg,board_para_pt2_avg] = flatness_calculation(targets_little_board,targets_xy,targets_Delta_pt1nk,targets_Delta_pt2nk,little_board_valid)

    board_para_pt1 = zeros(3,120);%平面度参数3*120，每一列是每个子板相对于指向单元1的平面度参数
    board_para_pt2 = zeros(3,120);%平面度参数3*120，每一列是每个子板相对于指向单元2的平面度参数
    board_para_pt1_avg=zeros(1,3); %平均平面度参数3*1，相对于pt1
    board_para_pt2_avg=zeros(1,3); %平均平面度参数3*1相对于pt2

    %把360*1的targets_Delta_pt1nk,targets_Delta_pt2nk扩展成480*1，能与targets_little_board对齐
    targets_Delta_pt1nk_480 = zeros(480,1);
    targets_Delta_pt2nk_480 = zeros(480,1);
    current_index = 1;
    
    % 遍历每一对需要复制的行
    for i = 1:6:360-4
       % 提取 4 行数据
       segment1 = targets_Delta_pt1nk(i:i+3);
       segment2 = targets_Delta_pt2nk(i:i+3);
       
       % 将提取的数据填充到targets_Delta_pt1nk_480 ， targets_Delta_pt2nk_480  中
       if current_index + 3 <= 480
        targets_Delta_pt1nk_480(current_index:current_index+3) = segment1;
        targets_Delta_pt2nk_480(current_index:current_index+3) = segment2;
        current_index = current_index + 4;
        
        % 提取下一组数据（前移 2 行）
        next_segment1 = targets_Delta_pt1nk(i+2:i+5);
        next_segment2 = targets_Delta_pt2nk(i+2:i+5);
        
        % 填充下一组数据到 expanded_data 中
            if current_index + 3 <= 480
                targets_Delta_pt1nk_480(current_index:current_index+3) = next_segment1;
                targets_Delta_pt2nk_480(current_index:current_index+3) = next_segment2;
                current_index = current_index + 4;
            end
        end
    end

    % 遍历每4个靶标有效信号
    for i = 1:4:length(targets_little_board)
        if i+3 <= length(targets_little_board)
            % 提取当前的4个数据
            segment = targets_little_board(i:i+3,3);  % 只取第三列

            % 找到表示无效信号靶标0的位置
            zero_indices = find(segment == 0);

            % 判断0的数量
            if isempty(zero_indices)     %每个小子板的靶标信号都有效
                part_xn=targets_xy(i:i+3,1); %提取靶标坐标xn
                part_yn=targets_xy(i:i+3,2); %提取靶标坐标yn
                ones_column=ones(4,1);      %四行一列的1
                A=[part_yn,-part_xn,ones_column];
                board_para_pt1(:,((i+3)/4))=(A'*A)\A'*targets_Delta_pt1nk_480(i:i+3); %小子板相对于指向单元1的平面度参数
                board_para_pt2(:,(i+3)/4)=(A'*A)\A'*targets_Delta_pt2nk_480(i:i+3); %小子板相对于指向单元2的平面度参数

            elseif length(zero_indices) == 1
                all_para_pt1 = zeros(480,3);   %480行，第一列为靶标xn坐标,第二列为靶标yn坐标，第三列为靶标相对于指向单元1的距离
                all_para_pt2 = zeros(480,3);   %480行，第一列为靶标xn坐标,第二列为靶标yn坐标，第三列为靶标相对于指向单元2的距离
                
                all_para_pt1(:,1)=targets_xy(:,1);
                all_para_pt2(:,1)=targets_xy(:,1);
                
                all_para_pt1(:,2)=targets_xy(:,2);
                all_para_pt2(:,2)=targets_xy(:,2);
                
                all_para_pt1(:,3)=targets_Delta_pt1nk_480;
                all_para_pt2(:,3)=targets_Delta_pt2nk_480;
                
                %靶标无效的信号的行数，或者无效的靶标总体编号
                segment_1=all_para_pt1(i:i+3,:);  %把all_para_pt1切片，分成4*3矩阵
                segment_2=all_para_pt2(i:i+3,:);  %把all_para_pt2切片，分成4*3矩阵
                
                segment_1(zero_indices, :) = [];  % 删除第zero_row行
                segment_2(zero_indices, :) = [];  % 删除第zero_row行
                
                A=zeros(3,3);
          
                A(:,1)=segment_1(:,2);   
                A(:,2)=-segment_1(:,1);
                A(:,3)=1;

                board_para_pt1(:,((i+3)/4))=(A'*A)\A'*segment_1(:,3); %小子板相对于指向单元1的平面度参数
                board_para_pt2(:,((i+3)/4))=(A'*A)\A'*segment_2(:,3); %小子板相对于指向单元2的平面度参数
                
            else
                board_para_pt1(:,((i+3)/4))=[0;0;0];
                board_para_pt2(:,((i+3)/4))=[0;0;0];
            end
        end
    end
    
    %格式修正
    board_para_pt1=board_para_pt1';
    board_para_pt2=board_para_pt2';
    
    %平面度参数总和
    sum_1_1=sum(board_para_pt1(:,1));
    sum_1_2=sum(board_para_pt1(:,2));
    sum_1_3=sum(board_para_pt1(:,3));
    
    sum_2_1=sum(board_para_pt2(:,1));
    sum_2_2=sum(board_para_pt2(:,2));
    sum_2_3=sum(board_para_pt2(:,3));
    
    %求平均平面度
    board_valid_cnt=sum(little_board_valid);
    
    board_para_pt1_avg(1)=sum_1_1/board_valid_cnt;
    board_para_pt1_avg(2)=sum_1_2/board_valid_cnt;
    board_para_pt1_avg(3)=sum_1_3/board_valid_cnt;
    board_para_pt2_avg(1)=sum_2_1/board_valid_cnt;
    board_para_pt2_avg(2)=sum_2_2/board_valid_cnt;
    board_para_pt2_avg(3)=sum_2_3/board_valid_cnt;
    
end

