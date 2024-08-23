clc
clear
close all

tic

data_in=xlsread("模拟输入.xlsx",'输入数据表');

%data_test=xlsread("模拟输入.xlsx",'自定义参数表');

targets_valid=ones(length(xlsread("模拟输入.xlsx",'靶标性质表')),1);
%靶标有效信号，若需要剔除某个靶标，请按靶标性质表的顺序将对应位置为0
%targets_valid(7:8)=0;

[board_flatness_pt1,board_flatness_pt2,board_flatness_pt1_avg,board_flatness_pt2_avg,delta_pt1_output,delta_pt2_output,delta_abs_output,global_flatness_pt1,global_flatness_pt2,abs_flatness]=main_function(data_in,targets_valid);

A=nansum(abs(delta_pt1_output-delta_pt2_output));%两个参考面计算得到的delta之差
B=board_flatness_pt1_avg-board_flatness_pt2_avg;%两个参考面计算得到的平均平面度参数之差

%展示靶标PSD排布情况
%figure(1);
%plot(targets_XY(:,1),targets_XY(:,2),'o');
%hold on;
%plot(targets_output_XY(:,1),targets_output_XY(:,2),'*');
%hold off;

toc