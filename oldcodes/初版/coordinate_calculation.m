function [targets_Delta_pt1nk, targets_Delta_pt2nk] = coordinate_calculation(targets_XY, targets_xy, targets_sigma_nk, targets_tau_pt1nk, targets_tau_pt2nk,targets_gamma,targets_epsilon,targets_location,targets_delta_pt1nk,targets_delta_pt2nk)
   CommonTargetsNum = find(targets_location == 3);%公共靶标编号
   CommonTargetsXY = targets_XY(CommonTargetsNum, :);%公共靶标坐标
   CommonTargetsDeltaPt1nk = ((-1).^(targets_gamma(CommonTargetsNum)+1)).*targets_delta_pt1nk(CommonTargetsNum) + ((-1).^(targets_epsilon(CommonTargetsNum)+1)).*targets_sigma_nk(CommonTargetsNum) + targets_tau_pt1nk(CommonTargetsNum);
   CommonTargetsDeltaPt2nk = ((-1).^(targets_gamma(CommonTargetsNum)+1)).*targets_delta_pt2nk(CommonTargetsNum) + ((-1).^(targets_epsilon(CommonTargetsNum)+1)).*targets_sigma_nk(CommonTargetsNum) + targets_tau_pt2nk(CommonTargetsNum);
   Delta = CommonTargetsDeltaPt1nk - CommonTargetsDeltaPt2nk;%方程右边
   B = [CommonTargetsXY(:, 2),(-1)*CommonTargetsXY(:, 1),ones(size(CommonTargetsNum, 1), 1)];%方程左边
   Bt = B';
   BtB = Bt * B;
   % 计算 (BtB)^-1 * Bt
   Cofficient = inv(BtB)*Bt;
   Skew = Cofficient*Delta;%解出方程
   Dnk = Skew(1)*targets_XY(:,2) - Skew(2)*targets_XY(:,1) + Skew(3);%%
   targets_Delta_pt1nk = ((-1).^(targets_gamma+1)).*targets_delta_pt1nk + ((-1).^(targets_epsilon+1)).*targets_sigma_nk + targets_tau_pt1nk;
   targets_Delta_pt2nk = ((-1).^(targets_gamma+1)).*targets_delta_pt2nk + ((-1).^(targets_epsilon+1)).*targets_sigma_nk + targets_tau_pt2nk;
   targets_Delta_pt1nk(targets_location == 2) = targets_Delta_pt2nk(targets_location == 2) + Dnk(targets_location == 2);
   targets_Delta_pt2nk(targets_location == 1) = targets_Delta_pt1nk(targets_location == 1) + Dnk(targets_location == 1);
end
