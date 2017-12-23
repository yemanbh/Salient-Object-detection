function [ PatternSalience ] = PatternDistinctness( I,labels,  numlabels)
%===========================================================
% developed by:
%               Yeman Brhane Hagos
%               Minh Vu
%==========================================================
%function [ PatternSalience ] = PatternDistinctness( I,labels,  numlabels)
%Input parameters are:
%[1] input images (color or grayscale)
%[2] Number of labels supperpixels
%[3] labels of of supperpixel
%
%Ouputs are:
%[1] pattern salience image

% the size of the supperpixels is diffrent so
% We starts equaliz the size of the supperpixels to average length so that
% it will be easy to put all superpixels in one patrix and find PRINCIPAL
% COMPUNET

% then PROJECT THE IMAGE PATHCES TO PRINCIPAL COMPONENTS
%compute distance in PRINCIPAL COMPONET COORDINATE to determine pattern
%distinctness
%% 
% mex slicmex.c
% %imshow(image)
% % 100% resolution 
% [labels, numlabels] = slicmex(image , 1000, 10);%numlabels is the same as number of superpixels
% % 50% resolution 
% im50= imresize(image, 0.5, 'bicubic');
% [labels50, numlabels50] = slicmex(im50 , 1000, 10);%numlabels is the same as number of superpixels
% 
% %Compute pattern Distinctness at 100% resolution
% PatternSalience100 = PatternDistinctness( image,labels,  numlabels);
% %Compute pattern Distinctness at 50% resolution
% PatternSalience50 = PatternDistinctness( im50,labels50,  numlabels50);
% 
%  Average of the two resolution distinctness
%  upscale the low resolution
% PatternSalience50= imresize(PatternSalience50, size(PatternSalience100), 'bicubic');
% PatternSalience= ( PatternSalience100 + PatternSalience50)/2;



%% Extrat pixels in each superpiuxel labels
    
%max(max(labels))
% Number of pixels in each supperpixel
numPixelPerSuper= zeros (1, numlabels);
%labelVariance= zeros (1, numlabels);% variance inside a patch

for i=1:numlabels
    numPixelPerSuper (i)= sum(sum(labels==( i - 1)));
end
% find minimum and maximum supperpixel size
maxSize=max(max(numPixelPerSuper));
minSize=min(min(numPixelPerSuper));

% Average length
avgSize = round ((maxSize + minSize)/2);

% Normalize the size to the avarage size by truncating and appending when
% needed. When appending I chose to append the last value and create image
% patchvector

imagePatch= zeros( avgSize, numlabels);

% Check if the image is RGB or greyscale image
[ m, n, d] = size ( I);
if n >1
%I = (I (:, : ,1) + I (:, : ,2) + I (:, : ,3))/3;
I = I (:, : ,1);
end

for i=1:numlabels
    
    [ row, col]= find (labels==(i-1));
    % This is Linear indexing
    idx = sub2ind(size(I), row, col);
    imagLabeli= I (idx);
    % convert pixel value to double and compute variance
    %labelVariance(i) = var (double((imagLabeli)));% variance of label=i pixels
    % check supperpixel size
    if numPixelPerSuper(i)>= avgSize 
        
        imagePatch(:,i) = imagLabeli(1:avgSize);
        
    else
        N= avgSize  - numPixelPerSuper(i); % appending size
        appendPix= imagLabeli(end) * uint8(ones(N, 1));
        imagePatch(:,i) =[imagLabeli ; appendPix ];
    end
end
% %% Take the 25% top variance patches
% NumpcaPatches = round (numlabels/4); %Number of pca patches
% sortedVar = sort (labelVariance,'descend');
% pcaPatchesPosition = [];
% i=1;
% while length(pcaPatchesPosition)> NumpcaPatches
%     x=find (labelVariance == sortedVar(i));
%     i = i +1;
%     pcaPatchesPosition = [pcaPatchesPosition x];
% end
% 
% % top variance patches
% 
% pcaPatches = zeros (avgSize , length (pcaPatchesPosition));
% 
% for i=1: length (pcaPatchesPosition)
%    pcaPatches (: , i)  =  imagePatch (: , pcaPatchesPosition  (i));
% end

%% Compute Average patch
%imagetranspos= imagePatch';
patchTrans = imagePatch';
avgPatch= mean(patchTrans);
avgPatch = avgPatch';

%% Concatinate average patch to image patches and compute PCA

newImagePtch= [ avgPatch, imagePatch ];

% subtract the mean
N= size (newImagePtch , 2);
ImageDiff=zeros(size(newImagePtch));
for i=1: N
    ImageDiff(: ,i)=newImagePtch(:, i)-avgPatch;
end
% Covariance of the image
T= ImageDiff';
ImageCov=1/N* ImageDiff * T;

% EigenValue decomposition

[V,D] = eig(ImageCov);

% Extract the eigenValues
eigenValues = diag(D);
sumEigen= sum(eigenValues);

% Dimenstion reduction: check how many principal components to take
for princComp=1: size(eigenValues , 1)
    
    percnt= sum ( eigenValues (1:princComp) )/ sumEigen;
    if percnt>= 0.95 && princComp >=2
        eigenRedu= eigenValues (1:princComp);
        break;
    end
end

% Number of dominant Princpal components
numPrincComp= princComp;

% Project the patches to the dominant principal components

projectedPatches= V(: , 1:princComp)' * newImagePtch;
% figure
% plot ( projectedPatches(1,:) , projectedPatches ( 2, :) , '.', 'color','g', 'markersize', 20);
% hold on
% %Average Pathch
% plot ( projectedPatches(1,1) , projectedPatches ( 2,1) , '.', 'color','r', 'markersize', 20);
% 
% title ('projection of superpixels onto the first two principal components');
% 
% xlabel('Principal Component 1');
% ylabel('Principal Component 2');

% legend ('Superpixels Patches', 'Average Patche');

%% Calculate distance along principal componets to determine salient patches

% Same as calculating L1 Norm distance along the principal components
    
% the first entry in the projectedPatches above is average patch

L1_distVector= zeros (1, N-1); % average patch   not included
avgPatchPC1= projectedPatches(1,1);
avgPatchPC2= projectedPatches ( 2,1);
for jj=2: N
    PatchPC1= projectedPatches(1,jj);
    PatchPC2= projectedPatches ( 2,jj);

   % Calculate distance
   avg2patch= [  avgPatchPC1 - PatchPC1, avgPatchPC2 - PatchPC2];
   L1_distVector(jj-1)= norm ( avg2patch , 1);
end

%Viewing the salent and non salient patches as scatter plot
% maxIndex = find (L1_distVector == max(L1_distVector));
% hold all;
% plot ( projectedPatches(1,maxIndex + 1) , projectedPatches ( 2,1 + maxIndex) , '.', 'color','b', 'markersize', 20);
% % Non salient
% minIndex = find (L1_distVector == min(L1_distVector));
% xx = sort (L1_distVector , 'ascend');
% minIndex = find (L1_distVector == xx(40));
% hold all;
% plot ( projectedPatches(1,minIndex + 1) , projectedPatches ( 2,1 + minIndex) , '.', 'color','y', 'markersize', 20);
% 
% legend ('Superpixels Patches', 'Average Patche' , 'Distinct patch', 'non distinct patch');

%% Assigning distance weight to the corresponding pixel values in thge orginal image

%[ m , n]= size (labels);
PatternSalience= zeros (size (labels));
for i=1:numlabels
    
    [ row, col]= find (labels==(i-1));
    % This is Linear indexing
    idx = sub2ind(size(labels), row, col);
    PatternSalience(idx) = L1_distVector( i );
end
% figure
% imshow (PatternSalience , [])
% title ('Pttern Salience');

end

