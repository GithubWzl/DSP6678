function [board_flatness_pt1,board_flatness_pt2,board_flatness_pt1_avg,board_flatness_pt2_avg,delta_pt1_output,delta_pt2_output,delta_abs_output,global_flatness_pt1,global_flatness_pt2,abs_flatness]=main_function(data_in,targets_valid)

%%
%从excel中读取固定的参数数据
data_board_div=xlsread("模拟输入.xlsx",'子区划分表');
data_targets_para=xlsread("模拟输入.xlsx",'靶标性质表');
data_output=xlsread("模拟输入.xlsx",'目标输出点表');

%参数设定
targets_cnt=length(data_targets_para);%靶标数量

%数据划分
PSD1_XY=data_targets_para(:,2:3);%PSD1在OXY平面的坐标
PSD2_XY=data_targets_para(:,4:5);%PSD2在OXY平面的坐标
targets_sigma_nk=data_targets_para(:,6);%靶标标定数值
targets_tau_pt1nk=data_targets_para(:,7);%指向单元1标定数值
targets_tau_pt2nk=data_targets_para(:,8);%指向单元2标定数值
targets_gamma=data_targets_para(:,9);%靶标γ值
targets_epsilon=data_targets_para(:,10);%靶标epsilon值
targets_location=data_targets_para(:,11);%接收来自参考面1/参考面2/或者公共靶标（标记3）
targets_phy_belong=data_targets_para(:,12);%靶标所属物理子板

PSD_valid1=data_in(:,2);%指示此时是哪个PSD在工作
PSD_valid2=data_in(:,3);%指示此时是哪个PSD在工作
targets_delta_pt1nk=data_in(:,4);%指向单元1对应靶标读数
targets_delta_pt2nk=data_in(:,5);%指向单元2对应靶标读数

targets_output_XY=data_output(:,1:2);%目标输出点坐标
targets_output_phy_belong=data_output(:,3);%目标输出点所属物理子板

targets_XY=zeros(targets_cnt,2);%工作中的PSD在OXY平面的坐标

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

%%
%去野值函数
%targets_outlier=outlier_marker(targets_XY);
%若为野值，输出为1，否则为0，输出格式为targets_cnt*1
targets_outlier=abs(randn(targets_cnt,1));targets_outlier(targets_outlier<1.5)=0;targets_outlier(targets_outlier>=1.5)=1;
%targets_outlier=zeros(targets_cnt,1);
%targets_outlier(1:4)=ones(4,1);

targets_outlier=logical(targets_outlier+~targets_valid);%将靶标有效信号和野值做逻辑处理

%去除野值后的子区划分
[data_board_div_valid,board_para]=board_div(data_board_div,targets_outlier);
%targets_little_board相比子区划分表去除掉了野值
%little_board_para大小为子区数量*3，第一列为子区编号，第二列为子区中有效的靶标数量

%子板局部坐标系计算
[targets_xy,board_o]=xy_calculation(data_board_div_valid,targets_XY,board_para);
%targets_xy大小为data_board_div_valid长度*2
%board_o代表局部坐标系原点位置，大小为子区数量*2，两列为坐标原点坐标

%%
%双指向单元处理和多扇形面拼接标定
[targets_Delta_pt1nk, targets_Delta_pt2nk]=coordinate_calculation(targets_outlier,targets_XY, targets_sigma_nk, targets_tau_pt1nk, targets_tau_pt2nk,targets_gamma,targets_epsilon,targets_location,targets_delta_pt1nk,targets_delta_pt2nk);
%输出每个靶标相比两个参考面的的Delta（三角形）

%平面度参数计算
[board_flatness_pt1,board_flatness_pt2,board_flatness_pt1_avg,board_flatness_pt2_avg]=flatness_calculation(data_board_div_valid,board_para,targets_xy,targets_Delta_pt1nk,targets_Delta_pt2nk,targets_XY,board_o,targets_outlier);
%输出两个参考面下的平面度参数和平均平面度

%%
%判断目标输出点属于哪个子板（判定标准：在物理子板范围内，距离局部坐标系原点最近）,并计算局部坐标系坐标值
[board_belong,targets_output_xy]=targets_output_judge(targets_output_XY,data_board_div,board_para,board_o,targets_phy_belong,targets_output_phy_belong);
%board_belong大小为目标输出点数量*1，表示目标输出点从属的子区编号
%targets_output_xy大小为目标输出点数量*2，表示目标输出点的局部坐标

%用计算目标输出点计算与两个参考面的距离、整体平面度、绝对平面度
[delta_pt1_output,delta_pt2_output,delta_abs_output,global_flatness_pt1,global_flatness_pt2,abs_flatness]=flatness_output(board_para,targets_output_xy,board_belong,board_flatness_pt1,board_flatness_pt2,board_flatness_pt1_avg,board_flatness_pt2_avg,targets_Delta_pt1nk,targets_Delta_pt2nk,data_board_div);

end