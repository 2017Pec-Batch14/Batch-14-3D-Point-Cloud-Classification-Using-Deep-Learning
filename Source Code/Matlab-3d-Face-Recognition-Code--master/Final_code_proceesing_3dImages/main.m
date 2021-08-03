clc;
clear all;
close all;

%  Using 2D or 3D affine matrix to rotate, translate, scale, reflect and
%  shear a 2D image or 3D volume. 2D image is represented by a 2D matrix,
%  3D volume is represented by a 3D matrix, and data type can be real 
%  integer or floating-point.
%
%  You may notice that MATLAB has a function called 'imtransform.m' for
%  2D spatial transformation. However, keep in mind that 'imtransform.m'
%  assumes y for the 1st dimension, and x for the 2nd dimension. They are
%  equivalent otherwise.
%
%  In addition, if you adjust the 'new_elem_size' parameter, this 'affine.m'
%  is equivalent to 'interp2.m' for 2D image, and equivalent to 'interp3.m'
%  for 3D volume.

view_nii;


%clip_nii;

%view_nii(nii);

