clc
clear
close all

tic

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
board_cnt=120;%小子板数量
PSD_per_target=2;%每个靶标对应的PSD数量

%数据划分
PSD1_XY=data_targets_para(:,2:3);%PSD1在OXY平面的坐标
PSD2_XY=data_targets_para(:,4:5);%PSD2在OXY平面的坐标
PSD_valid=data_in(:,2);%指示此时是哪个PSD在工作

targets_XY=zeros(targets_cnt,2);%工作中的PSD在OXY平面的坐标

for i=1:targets_cnt
    if PSD_valid(i)==1
        targets_XY(i,1)=PSD1_XY(i,1);targets_XY(i,2)=PSD1_XY(i,2);
    else
        targets_XY(i,1)=PSD2_XY(i,1);targets_XY(i,2)=PSD2_XY(i,2);
    end
end

%下列为给靶标坐标加入随机性，正式代码应删去
targets_XY=targets_XY+0.3*rand(size(targets_XY))-0.3;

%展示靶标PSD排布情况
figure(1);
plot(targets_XY(:,1),targets_XY(:,2),'o');
hold on;

targets_sigma_nk=data_targets_para(:,6);%靶标标定数值
targets_tau_pt1nk=data_targets_para(:,7);%指向单元1标定数值
targets_tau_pt2nk=data_targets_para(:,8);%指向单元2标定数值
targets_gamma=data_targets_para(:,9);%靶标γ值
targets_epsilon=data_targets_para(:,10);%靶标epsilon值
targets_is_public=data_targets_para(:,11);%靶标是否为公共靶标
targets_location=data_targets_para(:,12);%接收来自参考面1/参考面2/或者公共靶标（标记3）
targets_delta_pt1nk=data_in(:,3);%指向单元1对应靶标读数
targets_delta_pt2nk=data_in(:,4);%指向单元2对应靶标读数

targets_output_XY=data_output(1:100,6:7);%目标输出点坐标

plot(targets_output_XY(:,1),targets_output_XY(:,2),'*');
hold off;

%%
%去野值函数
%targets_outlier=outlier_marker(targets_XY);%若为野值，输出为1，否则为0，输出格式为targets_cnt*1
targets_outlier=abs(randn(targets_cnt,1));targets_outlier(targets_outlier<1.5)=0;targets_outlier(targets_outlier>=1.5)=1;

%子板划分
[targets_little_board,little_board_valid]=board_div(targets_outlier,board_cnt,targets_per_board,targets_per_phy_board);%targets_little_board大小为480*3，第一列为小子板编号，第二列为靶标整体编号，第三列为靶标有效信号。little_board_valid大小为120*1，表示小子板有效信号

%子板局部坐标系计算
[targets_xy,board_coordinate_para]=xy_calculation(targets_little_board,targets_XY,little_board_valid,board_cnt,targets_per_board);%targets_xy大小为480*2，与targets_little_board横向对齐；board_coordinate_para代表坐标系参数，大小为120*4，前两列为坐标原点坐标，第三列为矩形框宽度（X方向），第四列为矩形框高度（Y方向）

%%
%双指向单元处理和多扇形面拼接标定
[targets_Delta_pt1nk, targets_Delta_pt2nk] = coordinate_calculation(targets_outlier,targets_XY, targets_sigma_nk, targets_tau_pt1nk, targets_tau_pt2nk,targets_gamma,targets_epsilon,targets_location,targets_delta_pt1nk,targets_delta_pt2nk);%输出每个靶标相比两个参考面的的Delta（三角形），输入有点多懒得写了

%平面度参数计算
[board_para_pt1,board_para_pt2,board_para_pt1_avg,board_para_pt2_avg] = flatness_calculation(targets_little_board,targets_xy,targets_Delta_pt1nk,targets_Delta_pt2nk,little_board_valid);

%%
%判断目标输出点属于哪个子板（判定标准：在物理子板范围内，距离局部坐标系原点最近）,并计算局部坐标系坐标值
[board_belong,targets_output_xy] = targets_output_judge(targets_output_XY,board_coordinate_para);

%用计算目标输出点计算与两个参考面的距离、整体平面度、绝对平面度
[delta_pt1_output,delta_pt2_output,delta_abs_output,global_flatness_pt1,global_flatness_pt2,abs_flatness]=flatness_output(little_board_valid,targets_output_xy,board_belong,board_para_pt1,board_para_pt2,board_para_pt1_avg,board_para_pt2_avg);

toc