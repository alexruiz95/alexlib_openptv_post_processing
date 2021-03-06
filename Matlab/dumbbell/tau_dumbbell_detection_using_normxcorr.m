
% db2_1  = imread('C:\Documents and Settings\user\My Documents\My Dropbox\resuspension\scene 45 calibration files\db2_2.10674');
db2_1 = imread('../cam1_0000.TIF');
% bg1 = imread('C:\Documents and Settings\user\My Documents\My Dropbox\resuspension\cam4_emptyframe.TIF');
% 

% subtract background:
db2_1a = (imlincomb(1,db2_1,-1,bg1));
figure, imshow([db2_1,bg1,db2_1a])

% if the 'balls' are prepared, skip the following:
if ~exist('ball1','var') || isempty(ball1)
    % otherwise create it
    if exist('rect1','var') && ~isempty(rect1)
        ball1 = imcrop(db2_1a,rect1);
        ball2 = imcrop(db2_1a,rect2);
    else
        [ball1,rect1]  = imcrop(db2_1a);
        [ball2,rect2]  = imcrop(db2_1a);
    end
end

%% second time:


% image registration using normalized cross-correlation
% C = conv2(single(db2_1a),single(ball1(end:-1:1,end:-1:1)),'same');
C = normxcorr2_mex(double(ball1),double(db2_1a),'same');

% shiftx = ceil(size(ball1,1)/2);
% shifty = ceil(size(ball1,2)/2);
% C = C(shiftx:end-shiftx,shifty:end-shifty);

% find the peak - the "best" location
% [i1,j1] = find(C == max(C(:)));
[max_cc, imax] = max(abs(C(:)));
[i1, j1] = ind2sub(size(C),imax(1));

% option 1
% C = conv2(single(db2_1a),single(ball2(end:-1:1,end:-1:1)),'same');

% option2 
% C = normxcorr2(ball2,db2_1a);
% shiftx = ceil(size(ball2,1)/2);
% shifty = ceil(size(ball2,2)/2);
% C = C(shiftx:end-shiftx,shifty:end-shifty);


% option 3
C = normxcorr2_mex(double(ball2),double(db2_1a),'same');

% find the peak
[max_cc, imax] = max(abs(C(:)));
[i2, j2] = ind2sub(size(C),imax(1));

figure,imshow(db2_1a); hold on;
scatter(j1,i1,50,'ro','fill');
scatter(j2,i2,50,'go','fill');
