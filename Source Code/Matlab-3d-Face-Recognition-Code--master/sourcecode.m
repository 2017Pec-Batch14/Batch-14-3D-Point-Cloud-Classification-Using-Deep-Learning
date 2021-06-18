close all;clc;clear;% adding pathsfsep = '/';Path1 = sprintf(['..' fsep '..' fsep 'Wrappers/MATLAB/compiled'], 1i);Path2 = sprintf(['..' fsep '..' fsep 'Wrappers/MATLAB/supplem'], 1i);addpath(Path1); addpath(Path2); % Define phantom dimensionsN = 256; % x-y-z size (cubic image) % define parametersparamsObject.Ob = 'gaussian';paramsObject.C0 = 1; paramsObject.x0 = -0.25;paramsObject.y0 = 0.1;paramsObject.z0 = 0.0;paramsObject.a = 0.2;paramsObject.b = 0.35;paramsObject.c = 0.7;paramsObject.phi1 = 30;paramsObject.phi2 = 60;paramsObject.phi3 = -25; % generate 3D phantom [N x N x N]:tic; [G] = TomoP3DObject(paramsObject.Ob,paramsObject.C0, paramsObject.x0, paramsObject.y0, paramsObject.z0, paramsObject.a, paramsObject.b, paramsObject.c, paramsObject.phi1, paramsObject.phi2, paramsObject.phi3, N); toc; % check 3 projectionsfigure; slice = round(0.5*N);subplot(1,3,1); imagesc(G(:,:,slice), [0 1]); daspect([1 1 1]); colormap hot; title('Axial Slice');subplot(1,3,2); imagesc(squeeze(G(:,slice,:)), [0 1]); daspect([1 1 1]); colormap hot; title('Y-Slice');subplot(1,3,3); imagesc(squeeze(G(slice,:,:)), [0 1]); daspect([1 1 1]); colormap hot; title('X-Slice');


clear 
	close all
	fsep = '/';
	Path1 = sprintf(['..' fsep '..' fsep 'Wrappers/MATLAB/compiled'], 1i);
	Path2 = sprintf(['..' fsep '..' fsep 'Wrappers/MATLAB/supplem'], 1i);
	addpath(Path1); addpath(Path2); 
	
	% generate 3D phantom (modify your PATH bellow):
	curDir   = pwd;
	mainDir  = fileparts(curDir);
	pathtoLibrary = sprintf(['..' fsep '..' fsep 'PhantomLibrary' fsep 'models' fsep 'Phantom3DLibrary.dat'], 1i);
	pathTP = strcat(mainDir, pathtoLibrary); % path to TomoPhantom parameters file
	
	disp('Using TomoPhantom to generate 3D phantom');
	N = 256;
	ModelNo = 13;
	[G] = TomoP3DModel(ModelNo,N,pathTP);
	figure; 
	slice = round(0.5*N);
	subplot(1,3,1); imagesc(G(:,:,slice), [0 1]); daspect([1 1 1]); colormap hot; title('Axial Slice');
	subplot(1,3,2); imagesc(squeeze(G(:,slice,:)), [0 1]); daspect([1 1 1]); colormap hot; title('Y-Slice');
	subplot(1,3,3); imagesc(squeeze(G(slice,:,:)), [0 1]); daspect([1 1 1]); colormap hot; title('X-Slice');
	
	angles_num = round(0.5*pi*N); % angles number
	angles = linspace(0,179.99,angles_num); % projection angles
	Horiz_det = round(sqrt(2)*N); % detector column count (horizontal)
	Vert_det = N; % detector row count (vertical) (no reason for it to be > N, so fixed)
	%%
	disp('Using astra-toolbox (GPU) to generate 3D projection data');
	proj3D_astra = sino3Dastra(G, angles, Vert_det, Horiz_det);
	%%
	disp('Using TomoPhantom to generate 3D projection data');
	proj3D_tomophant = TomoP3DModelSino(ModelNo, Vert_det, Horiz_det, N, single(angles), pathTP);
	%%
	
	% comparing 2D analytical projections with ASTRA numerical projections
	slice2 = 160;
	compar_im = squeeze(proj3D_astra(:,slice2,:));
	sel_im = proj3D_tomophant(:,:,slice2);
	disp(norm(sel_im(:) - compar_im(:))/norm(compar_im(:)))
	
	% figure;imshow(squeeze(sino_tomophan3D(:,150,:)), []);
	max_val = 100;
	figure; 
	subplot(1,3,1); imagesc(sel_im, [0 max_val]); title('Analytical projection');
	subplot(1,3,2); imagesc(compar_im, [0 max_val]); title('Numerical projection');
	subplot(1,3,3); imagesc(abs(sel_im - compar_im), [0 max_val]); title('image error');
	
	figure; 
	subplot(1,3,1); imagesc(squeeze(proj3D_astra(:,slice2,:)), [0 max_val]); title('Astra projection');
	subplot(1,3,2); imagesc(squeeze(proj3D_astra(slice2,:,:)), [0 max_val]); title('Tangentogram');
	subplot(1,3,3); imagesc(squeeze(proj3D_astra(:,:,slice2)), [0 max_val]); title('Sinogram');
	
	figure; 
	subplot(1,3,1); imagesc(squeeze(proj3D_tomophant(:,:,slice2)), [0 max_val]); title('Analytical projection');
	subplot(1,3,2); imagesc(squeeze(proj3D_tomophant(slice2,:,:))', [0 max_val]); title('Tangentogram');
	subplot(1,3,3); imagesc(squeeze(proj3D_tomophant(:,slice2,:)), [0 max_val]); title('Sinogram');
	%%
	disp('Reconstructing data using ASTRA toolbox (CGLS method)');
	reconstructon = rec3Dastra(proj3D_tomophant, angles, Vert_det, Horiz_det);
	figure; 
	slice = round(0.5*N);
	subplot(1,3,1); imagesc(reconstructon(:,:,slice), [0 1]); daspect([1 1 1]); colormap hot; title('Axial Slice (reconstruction)');
	subplot(1,3,2); imagesc(squeeze(reconstructon(:,slice,:)), [0 1]); daspect([1 1 1]); colormap hot; title('Y-Slice');
	subplot(1,3,3); imagesc(squeeze(reconstructon(slice,:,:)), [0 1]); daspect([1 1 1]); colormap hot; title('X-Slice');

close all;clc;clear;
	% adding paths
	fsep = '/';
	Path1 = sprintf(['..' fsep '..' fsep 'Wrappers/MATLAB/compiled'], 1i);
	Path2 = sprintf(['..' fsep '..' fsep 'Wrappers/MATLAB/supplem'], 1i);
	addpath(Path1); addpath(Path2); 
	
	ModelNo = 4; % Select a model from Phantom2DLibrary.dat
	% Define phantom dimensions
	N = 512; % x-y size (squared image)
	
	% Generate 2D phantom:
	curDir   = pwd;
	mainDir  = fileparts(curDir);
	pathtoLibrary = sprintf(['..' fsep '..' fsep 'PhantomLibrary' fsep 'models' fsep 'Phantom2DLibrary.dat'], 1i);
	pathTP = strcat(mainDir, pathtoLibrary); % path to TomoPhantom parameters file
	[G] = TomoP2DModel(ModelNo,N,pathTP); 
	figure; imagesc(G, [0 1]); daspect([1 1 1]); colormap hot;
	%%
	fprintf('%s \n', 'Generating sinogram analytically and numerically using ASTRA-toolbox...');
	angles = linspace(0,180,N); % projection angles
	P = round(sqrt(2)*N); %detectors dimension
	% generate 2D analytical parallel beam sinogram (note the 'astra' opton)
	[F_a] = TomoP2DModelSino(ModelNo, N, P, single(angles), pathTP, 'astra'); 
	[F_num_astra] = sino2Dastra(G, (angles*pi/180), P, N, 'cpu');
	
	% calculate residiual norm (the error is expected since projection models not the same)
	err_diff = norm(F_a(:) - F_num_astra(:))./norm(F_num_astra(:));
	fprintf('%s %.4f\n', 'NMSE for sino residuals:', err_diff);
	
	figure; 
	subplot(1,2,1); imshow(F_a, []); title('Analytical Sinogram');
	subplot(1,2,2); imshow(F_num_astra, []); title('Numerical Sinogram (ASTRA)');
	%%
	fprintf('%s \n', 'Adding noise and artifacts to analytical sinogram...');
	dose =  1e4; % photon flux (controls noise level)
	[sino_noise] = add_noise(F_a, dose, 'Poisson'); % adding Poisson noise
	[sino_noise_zingers] = add_zingers(sino_noise, 0.5, 10); % adding zingers
	[sino_noise_zingers_stripes] = add_stripes(sino_noise_zingers, 1, 1); % adding stripes
	
	figure; imshow(sino_noise_zingers_stripes, []); title('Analytical Sinogram degraded with noise and artifacts');
	%%
	fprintf('%s \n', 'Reconstruction using ASTRA-toolbox (FBP)...');
	
	rec_an = rec2Dastra(sino_noise_zingers_stripes, (angles*pi/180), P, N, 'cpu');
	rec_num = rec2Dastra(F_num_astra, (angles*pi/180), P, N, 'cpu');
	
	figure; 
	subplot(1,2,1); imagesc(rec_an, [0 1]); daspect([1 1 1]); colormap hot; title('Degraded analytical sinogram reconstruction');
	subplot(1,2,2); imagesc(rec_num, [0 1]); daspect([1 1 1]); colormap hot; title('Numerical sinogram reconstruction');
	%%

	


close all;clc;clear;
	% adding paths
	fsep = '/';
	Path1 = sprintf(['..' fsep '..' fsep 'Wrappers/MATLAB/compiled'], 1i);
	Path2 = sprintf(['..' fsep '..' fsep 'Wrappers/MATLAB/supplem'], 1i);
	addpath(Path1); addpath(Path2); 
	
	
	% Define object dimensions
	N = 256; % x-y-z size (cubic image)
	
	% define parameters
	paramsObject.Ob = 'gaussian';
	paramsObject.C0 = 1; 
	paramsObject.x0 = -0.25;
	paramsObject.y0 = 0.1;
	paramsObject.a = 0.2;
	paramsObject.b = 0.35;
	paramsObject.phi1 = 30;
	
	% generate 2D phantom [N x N ]:
	[G1] = TomoP2DObject(paramsObject.Ob,paramsObject.C0, paramsObject.x0, paramsObject.y0, paramsObject.a, paramsObject.b, paramsObject.phi1, N);
	figure; imagesc(G1, [0 1]); daspect([1 1 1]); colormap hot;
	
	% generate corresponding 2D sinogram 
	angles = single(linspace(0,180,N)); % projection angles
	P = round(sqrt(2)*N);
	
	[F1] = TomoP2DObjectSino(paramsObject.Ob,paramsObject.C0, paramsObject.x0, paramsObject.y0, paramsObject.a, paramsObject.b, paramsObject.phi1, N, P, angles);
	figure; imagesc(F1, [0 50]); colormap hot;
	
	% generate another object 
	paramsObject.Ob = 'rectangle';
	paramsObject.C0 = 0.75; 
	paramsObject.x0 = 0.25;
	paramsObject.y0 = -0.1;
	paramsObject.a = 0.2;
	paramsObject.b = 0.4;
	paramsObject.phi1 = -45;
	
	[G2] = TomoP2DObject(paramsObject.Ob,paramsObject.C0, paramsObject.x0, paramsObject.y0, paramsObject.a, paramsObject.b, paramsObject.phi1, N);
	figure; imagesc(G2, [0 1]); daspect([1 1 1]); colormap hot;
	% generate corresponding 2D sinogram 
	[F2] = TomoP2DObjectSino(paramsObject.Ob,paramsObject.C0, paramsObject.x0, paramsObject.y0, paramsObject.a, paramsObject.b, paramsObject.phi1, N, P, angles);
	figure; imagesc(F2, [0 50]); colormap hot;
	
	% build a new model
	G = G1 + G2; 
	F = F1 + F2; 
	
	figure;
	subplot(1,2,1); imagesc(G, [0 1]); daspect([1 1 1]); colormap hot; title('New model');
	subplot(1,2,2); imagesc(F, [0 70]); daspect([1 1 1]); colormap hot; title('Sinogram');
	
	% reconstruct the model
	REC = rec2Dastra(F, double(angles*pi/180), P, N, 'cpu');
	figure; imagesc(REC, [0 1]); daspect([1 1 1]); colormap hot;




