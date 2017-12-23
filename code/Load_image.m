function Image_In=Load_image()
%===========================================================
% developed by:
%               Yeman Brhane Hagos
%               Minh Vu
%==========================================================
%No Input 
% Output: Image_In
% It raeds image
home=pwd;
[fileName,pathname]= uigetfile('*.*','Open Image');
% pathname
if fileName ~= 0 
cd(pathname);
Image_In=imread(fileName);
%Image_In(1:20,1:20);
 cd (home);
% pwd
% image = 255-double(image);
Image_In = uint8(Image_In);
end