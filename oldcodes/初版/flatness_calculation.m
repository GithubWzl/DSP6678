function [angle_x,angle_y,trans_z]=flatness_calculation()

%格式：每一行代表一个靶标，每行数据分别为：x，y，psd读数δ，0点到天线正面距离σ（包含正负信息，上方为负下方为正），靶标安装方向（-1正装+1倒装）
targets=[1,1,0.5;2,1,0.7;1,2,0.4;2,2,0.3];
