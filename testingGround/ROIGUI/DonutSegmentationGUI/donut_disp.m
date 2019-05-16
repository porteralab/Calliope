function varargout = donut_disp(varargin)
% DONUT_DISP MATLAB code for donut_disp.fig
%      DONUT_DISP, by itself, creates a new DONUT_DISP or raises the existing
%      singleton*.
%
%      H = DONUT_DISP returns the handle to a new DONUT_DISP or the handle to
%      the existing singleton*.
%
%      DONUT_DISP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DONUT_DISP.M with the given input arguments.
%
%      DONUT_DISP('Property','Value',...) creates a new DONUT_DISP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before donut_disp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to donut_disp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help donut_disp

% Last Modified by GUIDE v2.5 13-May-2014 22:39:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @donut_disp_OpeningFcn, ...
                   'gui_OutputFcn',  @donut_disp_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before donut_disp is made visible.
function donut_disp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to donut_disp (see VARARGIN)

% Choose default command line output for donut_disp
handles.output = hObject;
donut_addhandles('disp',hObject);
set(hObject,'toolbar','figure');
donut_initialization('disp');

addlistener(handles.SliderMain,'ContinuousValueChange',@(src,event) donut_dispslidermainfunc(hObject,handles));
addlistener(handles.SliderCMin,'ContinuousValueChange',@(src,event) donut_dispslidermainfunc(hObject,handles));
addlistener(handles.SliderCMax,'ContinuousValueChange',@(src,event) donut_dispslidermainfunc(hObject,handles));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes donut_disp wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function donut_dispslidermainfunc(hObject,handles)
global gh
gh.data.cFrame=round(get(gh.disp.SliderMain,'Value')*(gh.data.sze(3)-1)+1);
gh.data.cMax=get(gh.disp.SliderCMax,'Value');
gh.data.cMin=get(gh.disp.SliderCMin,'Value');
set(gh.disp.TextCFrame,'String',num2str(gh.data.cFrame));
donut_dispdrawfunc;
guidata(hObject,handles);


% --- Outputs from this function are returned to the command line.
function varargout = donut_disp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function SliderCMin_Callback(hObject, eventdata, handles)
% hObject    handle to SliderCMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderCMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderCMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function SliderCMax_Callback(hObject, eventdata, handles)
% hObject    handle to SliderCMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderCMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderCMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in ChckbxAddMask.
function ChckbxAddMask_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxAddMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_chckbxfunc(hObject);
% Hint: get(hObject,'Value') returns toggle state of ChckbxAddMask


% --- Executes on button press in ChckbxRemoveMask.
function ChckbxRemoveMask_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxRemoveMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_chckbxfunc(hObject);
% Hint: get(hObject,'Value') returns toggle state of ChckbxRemoveMask


% --- Executes on button press in ChckbxDispSF.
function ChckbxDispSF_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxDispSF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_dispdrawfunc;
% Hint: get(hObject,'Value') returns toggle state of ChckbxDispSF


% --- Executes on slider movement.
function SliderMain_Callback(hObject, eventdata, handles)
% hObject    handle to SliderMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderMain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in ChckbxDispAvg.
function ChckbxDispAvg_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxDispAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_dispdrawfunc;
% Hint: get(hObject,'Value') returns toggle state of ChckbxDispAvg


% --- Executes on button press in ChckbxLKDisp.
function ChckbxLKDisp_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxLKDisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_dispdrawfunc;
% Hint: get(hObject,'Value') returns toggle state of ChckbxLKDisp


% --- Executes during object creation, after setting all properties.
function AxesMain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AxesMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate AxesMain


% --- Executes on mouse press over axes background.
function AxesMain_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to AxesMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ChckbxDispSFIC.
function ChckbxDispSFIC_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxDispSFIC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_dispdrawfunc;
% Hint: get(hObject,'Value') returns toggle state of ChckbxDispSFIC


% --- Executes on button press in ChckbxPlotDF.
function ChckbxPlotDF_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxPlotDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_chckbxfunc(hObject);
% Hint: get(hObject,'Value') returns toggle state of ChckbxPlotDF


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gh
gh.disp.opened=0;
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in ChckbxDispMaskNum.
function ChckbxDispMaskNum_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxDispMaskNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_dispdrawfunc;
% Hint: get(hObject,'Value') returns toggle state of ChckbxDispMaskNum


% --- Executes on button press in ChckbxRegularizeMask.
function ChckbxRegularizeMask_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxRegularizeMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ChckbxRegularizeMask


% --- Executes on button press in ChckbxChangeMask.
function ChckbxChangeMask_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxChangeMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_chckbxfunc(hObject);
% Hint: get(hObject,'Value') returns toggle state of ChckbxChangeMask


% --- Executes on button press in ChckbxDilateMask.
function ChckbxDilateMask_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxDilateMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_chckbxfunc(hObject);
% Hint: get(hObject,'Value') returns toggle state of ChckbxDilateMask


% --- Executes on button press in ChckbxDraw.
function ChckbxDraw_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxDraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_chckbxfunc(hObject);
% Hint: get(hObject,'Value') returns toggle state of ChckbxDraw


% --- Executes on button press in ChckbxErase.
function ChckbxErase_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxErase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_chckbxfunc(hObject);
% Hint: get(hObject,'Value') returns toggle state of ChckbxErase


% --- Executes during object creation, after setting all properties.
function ChckbxDraw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChckbxDraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in ChckbxDispCluster.
function ChckbxDispCluster_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxDispCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_dispdrawfunc;
% Hint: get(hObject,'Value') returns toggle state of ChckbxDispCluster
