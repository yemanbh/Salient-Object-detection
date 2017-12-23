
%=========================================================================
%  Implemented by     BY: YEMAN BRHANE HAGOS and
%                          MINH VU
%=========================================================================
clc;
close all;
clear;

% compiles and links SLIC source files into a binary MEX-file, callable from MATLAB
mex slicmex.c
%% ******************** CREATE fIGURE ****************************************

F= figure('Position',[100 40 1130 700],...
   'Name','','menubar','none',...
  'resize','off',...
   'NumberTitle','off');


Background=get(F,'Color');
%TITLE
 Title= uicontrol('parent',F,'Style','text','Position',[350 650 500 50],...
     'string','Salent Patch Based Object Detection', 'background', Background ,...
     'horizontalAlignment','center', 'FontSize',18,'FontWeight','bold');
%% Panels

% FOR BUTTONS
panel = uipanel('parent',F,'Title','','FontSize',12,...
    'BackgroundColor',Background,...
    'units','pixel','Position',[0 0 330 650]);
% FOR AXES
InputImagesPanel= uipanel('parent',F,'Title','','FontSize',12,...
             'BackgroundColor',Background,'BorderType','none',...
             'units','pixel','Position',[330,0,400,650]);

         
 %% Button Groups
 X=50;
 W=220;
 H=30;
 Y=50;
 gap=40;
text1='Input image';
interpolate='bicubic';
LoadImage=uicontrol('parent',panel,'string','Select Image','callback',...
    ['Input_im=Load_image();'...
    'subplot(Axes1);'...
    'imshow(Input_im,[]);'...
    '[labels, numlabels] = slicmex(Input_im , 1000, 10);',...
    'im50= imresize(Input_im, 0.5, interpolate);',...
    '[labels50, numlabels50] = slicmex(im50 , 1000, 10);',...
    'title(text1);'],'FontSize',18, 'Position',[X 550 W H]);


p='Pattern Distinctness';
%Segmented_im=dicomread('final_TEP_labels.dcm');
patternButton=uicontrol('parent',panel,'string','Distinct Pattern','callback',...
   [%Compute pattern Distinctness at 100% resolution
    'PatternSalience100 = PatternDistinctness( Input_im,labels,  numlabels);',...
    'PatternSalience50 = PatternDistinctness( im50,labels50,  numlabels50);',... %Compute pattern Distinctness at 50% resolution
    'PatternSalience50= imresize(PatternSalience50, size(PatternSalience100), interpolate);',...% Average of the two resolution distinctness
    'PatternSalience= ( PatternSalience100 + PatternSalience50)/2;',...
    'subplot(Axes2);'...% axes 3 and 4
    'imshow(PatternSalience, []);'...
    'title(p);'],'FontSize',18,'Position',[X 470 W H]);

text3='Color Distinctness';
colorButton=uicontrol('parent',panel,'string','Distinct Color','callback',...
   [% Compute Color Distinctness at diffrent resolution
   ' colorSalience100 = colorDistnictness( Input_im, labels, numlabels );',...%Compute color Distinctness at 50% resolution
    'colorSalience50 = colorDistnictness( im50,labels50,  numlabels50);',...% Average of the two resolution distinctness
    'colorSalience50= imresize(colorSalience50, size(colorSalience100), interpolate);',...
    'colorSalience= ( colorSalience100 + colorSalience50)/2;',...
    'subplot(Axes3);'...
    'imshow(colorSalience,[]);'...
    'title(text3);'],'FontSize',18,'Position',[X 390 W H]);


salience='Final Saliency';
demo=uicontrol('parent',panel,'string','Final Saliency','callback',...
    [
    'finalSliancy = combine_prior( PatternSalience ,  colorSalience);'...
    'subplot(Axes4);'...
    'imshow(finalSliancy);'...
    'title(salience);'],'FontSize',18,'Position',[X 310 W H]);


%% Help
Background=get(panel,'backgroundColor');
label= uicontrol('parent',panel,'Style','text','Position',[X 200 W H],...
    'string','How to use the software', 'background', [0.5 0.5 0.5],'horizontalAlignment','center', 'FontSize',12); % create a listbox object
h = uicontrol('parent',panel,'Style','text','Position',[X 80 W 120],...
      'min',0,'max',2,'enable','inactive','background', [0.8 0.8 0.9],'horizontalAlignment','left','FontSize',12); % create a listbox object
%str = {['']};
set(h,'string',{'1. Select Image';'2. Press Pattern Distinct';...
    '3. Press Pattern Distinct';'4. Press Final Saliency'});
%set(h,'String',str) % display the string



%% *********** AXES TO DISPLAY INPUT *****************

Axes1=axes('parent',InputImagesPanel,'units','pixel','position',[0,320,420,280],'Box','off');
%set(Axes1,'color',Background);
Axes1.Color=Background;
Axes1.XTick=[]; Axes1.YTick=[];

Axes2=axes('parent',InputImagesPanel,'units','pixel','position',[0,5,420,280],'Box','off');
Axes2.Color=Background;
Axes2.XTick=[]; Axes2.YTick=[];
set(Axes1, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])



%% *********** AXES TO DISPLAY OUTPUT *****************
OutputImagesPqnel= uipanel('parent',F,'Title','','FontSize',12,...
             'BackgroundColor',Background,'BorderType','none',...
             'units','pixel','Position',[750,0,400,650]);
Axes3=axes('parent',OutputImagesPqnel,'units','pixel','position',[0,320,420,280],'Box','off');
%set(Axes1,'color',Background);
Axes3.Color=Background;
Axes3.XTick=[]; Axes3.YTick=[];

Axes4=axes('parent',OutputImagesPqnel,'units','pixel','position',[0,5,420,280],'Box','off');
Axes4.Color=Background;
Axes4.XTick=[]; Axes4.YTick=[];

