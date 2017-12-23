function [ colorSalience ] = colorDistnictness( I, labels, numlabels )
%===========================================================
% developed by:
%               Yeman Brhane Hagos
%               Minh Vu
%==========================================================
%function [ colorSalience ] = colorDistnictness( I, labels, numlabels )
%  %Input parameters are:
%[1] input images (color or grayscale)
%[2] Number of labels of supperpixels
%[3] labels of of supperpixel
%
%Ouputs are:
%[1] color salience image

% The color saliency is computed as follows
% 1. We compute average color of every supperpixel
% 2. For each supperpioxel we compute sum of  L2 norm distance of its
% verage color from all other supperpixels average color
% lastsly, we return the distance as color saliency
%% Color Distnictness


%[labels, numlabels] = slicmex(image , 600, 10);

% Check if thge image is RGB or greyscale image
% [ m, n, d] = size ( image);
% if n ~= 1
%I = (image (:, : ,1) + image (:, : ,2) + image (:, : ,3))/3;
R = I (:, : ,1);
G = I (:, : ,2);
B = I (:, : ,3);
% end
% Average color of each superpixel
meanColorSuperPixcel= zeros (numlabels , 3);
for Labl=1:numlabels
    
    [ row, col]= find (labels==(Labl-1));
    % This is Linear indexing of each clor space 
    idx = sub2ind(size(R), row, col); % idxR=idxG=idxy
    
%     idxG = sub2ind(size(G), row, col);
%     idxB = sub2ind(size(B), row, col);

    % average color of supperpixels
    avgRed= mean(R(idx));
    avggreen= mean(G(idx));
    avgBlu= mean(B(idx));
    meanColorSuperPixcel ( Labl , :) = [ avgRed , avggreen , avgBlu];
end

% % Distance Calulation and assigning color disntinctness

colorSalience= zeros (size (labels));
for L=1:numlabels
    
    colorDist=0;
    
    for x=1:numlabels
        colorDif = meanColorSuperPixcel ( L, :) - meanColorSuperPixcel ( x , :);
        colorDist = colorDist + norm ( colorDif , 1);
        
    end
    % substituting the color saliency in the image
    [ row, col]= find (labels==(L-1));
    % This is Linear indexing
    idx = sub2ind(size(labels), row, col);
    colorSalience(idx) = colorDist;
end

% figure
% imshow (colorSalience , [])
% title ('Color Salience ');

end


