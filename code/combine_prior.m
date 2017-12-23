function [ finalSliancy ] = combine_prior( PatternSalience ,  colorSalience)
%===========================================================
% developed by:
%               Yeman Brhane Hagos
%               Minh Vu
%==========================================================
%function [ finalSliancy ] = combine_prior( PatternSalience ,  colorSalience)

%Input parameters are:
%[1] PatternSalience from pattern distinctness
%[2] colorSalience from color distinctness
%
%
%Ouputs are:
%[1] finalSliancy
%
% the final saliency is comuted as follows
%1. we combine pattern and color saliency
%2. Incorpoprating known priors
    %1. we note that the salient pixels tend to be grouped together into clusters, as they typically
    %correspond to real objects in the scene. this is done computing
    %centermass of the salient object and puting gaussian at that point
    % 2. Photographers put salient object at center : this is done by
    % puting Gaussian at centerof the combined saliency image

%% Combining pattern and color salience

combinedSaliancy= PatternSalience .* colorSalience;

% Normalization
 combinedSaliancyNor = combinedSaliancy / max (max (combinedSaliancy));
    % figure
    % imshow (combinedSaliancy , [])
    % title ('Comined Salience ');

%% Incorpoprating known priors
%% 1. we note that the salient pixels tend to be grouped together into clusters, as they typically
%correspond to real objects in the scene
[ N, M]= size (combinedSaliancy);
level = graythresh(combinedSaliancyNor);
BW = im2bw(combinedSaliancyNor,level);
%         figure
%         imshow(BW)
% Find Center mass of the salient object and place Gaussian 
[row , col]=find (BW==1);
% Center Mass
Center=round ([ sum(row), sum(col)]/ length(row));
% Determine size of Gaussian
x = N-Center(1);
y= M-Center(2);
r= max(Center(1), x);
c= max(Center(2), y);
% Generate Gaussian with center at center mass
gaussian= fspecial('gaussian', [ 2*r 2*c], 1000);
gaussian=gaussian(r+1-Center(1):r+x,c+1-Center(2):c+y);
% size(h)
%  figure
%  imshow(h, [])
SaliencyImage=combinedSaliancy.*( gaussian);
%% 2. Photographers put salient object at center : Gaussian at center
        %gausswidth= max (size (combinedSaliancy));
% determine sigma
        %sigma= (gausswidth - 1)/ 6; % this one is bluring the pixels at edge

% generate guassian at center
 gaussianCenter = fspecial('gaussian', size (SaliencyImage), 100);
 
 finalSliancy = SaliencyImage .* (5 * gaussianCenter);
 
%          figure
%         imshow (finalSliancy , [])
%         title ('final Salience ');
end

