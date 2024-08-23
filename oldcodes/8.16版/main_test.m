clc
clear
close all
%%
%模拟输入数据，每行代表一个靶标数据，行数为靶标总体标号
data_targets_on_boards=xlsread("模拟输入.xlsx",'Sheet1');
data_targets_para=xlsread("模拟输入.xlsx",'Sheet2');
data_output=xlsread("模拟输入.xlsx",'Sheet3');
data_in=xlsread("模拟输入.xlsx",'Sheet4');

%参数设定
targets_cnt=length(data_targets_para);%靶标数量
targets_per_phy_board=6;%每个物理子板上靶标数量
targets_per_board=4;%每个小子板上靶标数量
board_cnt=20;%小子板数量
PSD_per_target=2;%每个靶标对应的PSD数量
avg_method=2;%1：平均平面度计算每个子区平面度的平均值；2：平均平面度计算全部点的平面度

%数据划分
PSD1_XY=data_targets_para(:,2:3);%PSD1在OXY平面的坐标
PSD2_XY=data_targets_para(:,4:5);%PSD2在OXY平面的坐标
PSD_valid1=data_in(:,2);%指示此时是哪个PSD在工作
PSD_valid2=data_in(:,3);%指示此时是哪个PSD在工作

targets_XY=zeros(targets_cnt,2);%工作中的PSD在OXY平面的坐标

targets_sigma_nk=data_targets_para(:,6);%靶标标定数值
targets_tau_pt1nk=data_targets_para(:,7);%指向单元1标定数值
targets_tau_pt2nk=data_targets_para(:,8);%指向单元2标定数值
targets_gamma=data_targets_para(:,9);%靶标γ值
targets_epsilon=data_targets_para(:,10);%靶标epsilon值
targets_is_public=data_targets_para(:,11);%靶标是否为公共靶标
targets_location=data_targets_para(:,12);%接收来自参考面1/参考面2/或者公共靶标（标记3）
targets_delta_pt1nk=data_in(:,4);%指向单元1对应靶标读数
targets_delta_pt2nk=data_in(:,5);%指向单元2对应靶标读数

targets_output_XY=data_output(1:100,6:7);%目标输出点坐标

for i=1:targets_cnt
    if targets_location==3
        if PSD_valid1==PSD_valid2
            if PSD_valid1==1
                targets_XY(i,1)=PSD1_XY(i,1);targets_XY(i,2)=PSD1_XY(i,2);
            else
                targets_XY(i,1)=PSD2_XY(i,1);targets_XY(i,2)=PSD2_XY(i,2);
            end
        else
            targets_XY(i,1)=0.5*PSD1_XY(i,1)+0.5*PSD2_XY(i,1);targets_XY(i,2)=0.5*PSD1_XY(i,2)+0.5*PSD2_XY(i,2);
        end
    elseif targets_location==1
        if PSD_valid1(i)==1
            targets_XY(i,1)=PSD1_XY(i,1);targets_XY(i,2)=PSD1_XY(i,2);
        else
            targets_XY(i,1)=PSD2_XY(i,1);targets_XY(i,2)=PSD2_XY(i,2);
        end
    else
        if PSD_valid2(i)==1
            targets_XY(i,1)=PSD1_XY(i,1);targets_XY(i,2)=PSD1_XY(i,2);
        else
            targets_XY(i,1)=PSD2_XY(i,1);targets_XY(i,2)=PSD2_XY(i,2);
        end
    end
end

%下列为给靶标坐标加入随机性，正式代码应删去
%targets_XY=targets_XY+0.3*rand(size(targets_XY))-0.3;

%展示靶标PSD排布情况
% figure(1);
% plot(targets_XY(:,1),targets_XY(:,2),'o');
% xlim([0 16]);
% ylim([0 5]);
% hold on;

% plot(targets_output_XY(:,1),targets_output_XY(:,2),'*');
% hold off;

%%
%去野值函数
%targets_outlier=outlier_marker(targets_XY);%若为野值，输出为1，否则为0，输出格式为targets_cnt*1
%targets_outlier=abs(randn(targets_cnt,1));targets_outlier(targets_outlier<1.5)=0;targets_outlier(targets_outlier>=1.5)=1;
targets_outlier=zeros(60,1);

%子板划分
[targets_little_board,little_board_valid]=board_div(targets_outlier,board_cnt,targets_per_board,targets_per_phy_board);%targets_little_board大小为480*3，第一列为小子板编号，第二列为靶标整体编号，第三列为靶标有效信号。little_board_valid大小为120*1，表示小子板有效信号
%子板局部坐标系计算
[targets_xy,board_coordinate_para]=xy_calculation(targets_little_board,targets_XY,little_board_valid,board_cnt,targets_per_board);%targets_xy大小为480*2，与targets_little_board横向对齐；board_coordinate_para代表坐标系参数，大小为120*4，前两列为坐标原点坐标，第三列为矩形框宽度（X方向），第四列为矩形框高度（Y方向）

%%
%输出计算
data_test=xlsread("模拟输入.xlsx",'自定义参数表');
MigrationParameter1 = data_test(1:20,2:4)';%相对参考面1偏移参数
MigrationParameter2 = data_test(1:20,5:7)';%相对参考面2偏移参数
B = [targets_xy(:, 2),(-1)*targets_xy(:, 1),ones(size(targets_xy, 1), 1)];%公式1局部坐标系矩阵
% 初始化输出矩阵
outputMatrix1 = zeros(80, 1);  % 结果矩阵的大小为 80×1
outputMatrix2 = zeros(80, 1);  % 结果矩阵的大小为 80×1
% 进行逐组逐列相乘，得到有重复数据输出
for i = 1:20
    % 取 B 中的 4×3 子矩阵
    B_sub = B((i-1)*4+1:i*4, :);
    % 取 MigrationParameter1 中的第 i 列
    M_col1 = MigrationParameter1(:, i);
    M_col2 = MigrationParameter2(:, i);
    % 进行矩阵乘法
    result_sub1 = B_sub * M_col1;
    result_sub2 = B_sub * M_col2;
    % 将结果存储到输出矩阵的相应位置
    outputMatrix1((i-1)*4+1:i*4) = result_sub1;
    outputMatrix2((i-1)*4+1:i*4) = result_sub2;
end
% 删除公共靶标重复数据
rowskeep = ones(length(outputMatrix1),1);
for i=3:8:length(outputMatrix1)
    rowskeep(i) = 0;rowskeep(i+1) = 0;
end
deltapt1nk= outputMatrix1(rowskeep==1);
deltapt2nk= outputMatrix2(rowskeep==1);

writematrix(deltapt1nk, '模拟输入.xlsx', 'Sheet', '自定义参数表', 'Range', 'J2');
writematrix(deltapt2nk, '模拟输入.xlsx', 'Sheet', '自定义参数表', 'Range', 'K2');