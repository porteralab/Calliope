function varargout = donut_main(varargin)
% DONUT_MAIN MATLAB code for donut_main.fig
%      DONUT_MAIN, by itself, creates a new DONUT_MAIN or raises the existing
%      singleton*.
%
%      H = DONUT_MAIN returns the handle to a new DONUT_MAIN or the handle to
%      the existing singleton*.
%
%      DONUT_MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DONUT_MAIN.M with the given input arguments.
%
%      DONUT_MAIN('Property','Value',...) creates a new DONUT_MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before donut_main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to donut_main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help donut_main

% Last Modified by GUIDE v2.5 13-May-2014 23:41:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @donut_main_OpeningFcn, ...
                   'gui_OutputFcn',  @donut_main_OutputFcn, ...
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


% --- Executes just before donut_main is made visible.
function donut_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to donut_main (see VARARGIN)
% donut_addhandles('main',hObj);
% Choose default command line output for donut_main
handles.output = hObject;
donut_addhandles('main',hObject);
donut_initialization('main');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes donut_main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = donut_main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in BttnLoadFile.
function BttnLoadFile_Callback(hObject, eventdata, handles)
% hObject    handle to BttnLoadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_loadfunc;


function EditFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to EditFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditFilePath as text
%        str2double(get(hObject,'String')) returns contents of EditFilePath as a double


% --- Executes during object creation, after setting all properties.
function EditFilePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BttnShutDown.
function BttnShutDown_Callback(hObject, eventdata, handles)
% hObject    handle to BttnShutDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection=questdlg('Do you want to shut down/restart the GUI?','Close Request','Shutdown','Restart','Cancel','Cancel');
switch selection
    case 'Restart'
        donut_shutdownfunc;
        donut_main;
    case 'Shutdown'
        donut_shutdownfunc;
    case 'No'
        return
end


function EditNumParam_Callback(hObject, eventdata, handles)
% hObject    handle to EditNumParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_editfunc(hObject);
% Hints: get(hObject,'String') returns contents of EditNumParam as text
%        str2double(get(hObject,'String')) returns contents of EditNumParam as a double


% --- Executes during object creation, after setting all properties.
function EditNumParam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditNumParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditConvCret_Callback(hObject, eventdata, handles)
% hObject    handle to EditConvCret (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_editfunc(hObject);
% Hints: get(hObject,'String') returns contents of EditConvCret as text
%        str2double(get(hObject,'String')) returns contents of EditConvCret as a double


% --- Executes during object creation, after setting all properties.
function EditConvCret_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditConvCret (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditNumLoop_Callback(hObject, eventdata, handles)
% hObject    handle to EditNumLoop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_editfunc(hObject);
% Hints: get(hObject,'String') returns contents of EditNumLoop as text
%        str2double(get(hObject,'String')) returns contents of EditNumLoop as a double


% --- Executes during object creation, after setting all properties.
function EditNumLoop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditNumLoop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SliderNumParam_Callback(hObject, eventdata, handles)
% hObject    handle to SliderNumParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderNumParam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderNumParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function SliderConvCret_Callback(hObject, eventdata, handles)
% hObject    handle to SliderConvCret (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderConvCret_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderConvCret (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function SliderNumLoop_Callback(hObject, eventdata, handles)
% hObject    handle to SliderNumLoop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderNumLoop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderNumLoop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function EditSig1_Callback(hObject, eventdata, handles)
% hObject    handle to EditSig1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_editfunc(hObject);
% Hints: get(hObject,'String') returns contents of EditSig1 as text
%        str2double(get(hObject,'String')) returns contents of EditSig1 as a double


% --- Executes during object creation, after setting all properties.
function EditSig1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSig1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditSig2_Callback(hObject, eventdata, handles)
% hObject    handle to EditSig2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_editfunc(hObject);
% Hints: get(hObject,'String') returns contents of EditSig2 as text
%        str2double(get(hObject,'String')) returns contents of EditSig2 as a double


% --- Executes during object creation, after setting all properties.
function EditSig2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSig2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SliderSig1_Callback(hObject, eventdata, handles)
% hObject    handle to SliderSig1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderSig1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderSig1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function SliderSig2_Callback(hObject, eventdata, handles)
% hObject    handle to SliderSig2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderSig2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderSig2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in BttnInferDonut.
function BttnInferDonut_Callback(hObject, eventdata, handles)
% hObject    handle to BttnInferDonut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_inferfunc(0);

% --- Executes on button press in BttnRunLK.
function BttnRunLK_Callback(hObject, eventdata, handles)
% hObject    handle to BttnRunLK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_runLK;

% --- Executes on button press in ChckbxAddDonut.
function ChckbxAddDonut_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxAddDonut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ChckbxAddDonut


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in BttnReset.
function BttnReset_Callback(hObject, eventdata, handles)
% hObject    handle to BttnReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_resetparamfunc({'Sig1';'Sig2'},{1.2;1.5});


function EditNumPC_Callback(hObject, eventdata, handles)
% hObject    handle to EditNumPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_editfunc(hObject);
% Hints: get(hObject,'String') returns contents of EditNumPC as text
%        str2double(get(hObject,'String')) returns contents of EditNumPC as a double


% --- Executes during object creation, after setting all properties.
function EditNumPC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditNumPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditNumIC_Callback(hObject, eventdata, handles)
% hObject    handle to EditNumIC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_editfunc(hObject);
% Hints: get(hObject,'String') returns contents of EditNumIC as text
%        str2double(get(hObject,'String')) returns contents of EditNumIC as a double


% --- Executes during object creation, after setting all properties.
function EditNumIC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditNumIC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SliderNumPC_Callback(hObject, eventdata, handles)
% hObject    handle to SliderNumPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderNumPC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderNumPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function SliderNumIC_Callback(hObject, eventdata, handles)
% hObject    handle to SliderNumIC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderNumIC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderNumIC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in BttnICA.
function BttnICA_Callback(hObject, eventdata, handles)
% hObject    handle to BttnICA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_icafunc(0);


function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SliderChangeFilter_Callback(hObject, eventdata, handles)
% hObject    handle to SliderChangeFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderChangeFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderChangeFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_resetparamfunc({'NumPC';'NumIC'},{2;2});


function EditInclCret_Callback(hObject, eventdata, handles)
% hObject    handle to EditInclCret (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_editfunc(hObject);
% Hints: get(hObject,'String') returns contents of EditInclCret as text
%        str2double(get(hObject,'String')) returns contents of EditInclCret as a double


% --- Executes during object creation, after setting all properties.
function EditInclCret_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditInclCret (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SliderInclCret_Callback(hObject, eventdata, handles)
% hObject    handle to SliderInclCret (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderInclCret_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderInclCret (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in ChckbxInferReg.
function ChckbxInferReg_Callback(hObject, eventdata, handles)
% hObject    handle to ChckbxInferReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ChckbxInferReg


% --- Executes on button press in BttnTransposeIm.
function BttnTransposeIm_Callback(hObject, eventdata, handles)
% hObject    handle to BttnTransposeIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gh
gh.data.ImRaw=permute(gh.data.ImRaw,[2 1 3]);
gh.data.ImRawAvg=gh.data.ImRawAvg';



function EditNumRing_Callback(hObject, eventdata, handles)
% hObject    handle to EditNumRing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_editfunc(hObject);
% Hints: get(hObject,'String') returns contents of EditNumRing as text
%        str2double(get(hObject,'String')) returns contents of EditNumRing as a double


% --- Executes during object creation, after setting all properties.
function EditNumRing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditNumRing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SliderNumRing_Callback(hObject, eventdata, handles)
% hObject    handle to SliderNumRing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderNumRing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderNumRing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in BttnAddPixels.
function BttnAddPixels_Callback(hObject, eventdata, handles)
% hObject    handle to BttnAddPixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gh
donut_refinemask(1:size(gh.data.ix,1));


function EditCretCorr2_Callback(hObject, eventdata, handles)
% hObject    handle to EditCretCorr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_editfunc(hObject);
% Hints: get(hObject,'String') returns contents of EditCretCorr2 as text
%        str2double(get(hObject,'String')) returns contents of EditCretCorr2 as a double


% --- Executes during object creation, after setting all properties.
function EditCretCorr2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCretCorr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SliderCretCorr2_Callback(hObject, eventdata, handles)
% hObject    handle to SliderCretCorr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderCretCorr2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderCretCorr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function EditCretCorr1_Callback(hObject, eventdata, handles)
% hObject    handle to EditCretCorr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_editfunc(hObject);
% Hints: get(hObject,'String') returns contents of EditCretCorr1 as text
%        str2double(get(hObject,'String')) returns contents of EditCretCorr1 as a double


% --- Executes during object creation, after setting all properties.
function EditCretCorr1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCretCorr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SliderCretCorr1_Callback(hObject, eventdata, handles)
% hObject    handle to SliderCretCorr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderCretCorr1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderCretCorr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function EditCretCorr0_Callback(hObject, eventdata, handles)
% hObject    handle to EditCretCorr0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_editfunc(hObject);
% Hints: get(hObject,'String') returns contents of EditCretCorr0 as text
%        str2double(get(hObject,'String')) returns contents of EditCretCorr0 as a double


% --- Executes during object creation, after setting all properties.
function EditCretCorr0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCretCorr0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SliderCretCorr0_Callback(hObject, eventdata, handles)
% hObject    handle to SliderCretCorr0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderCretCorr0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderCretCorr0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in PopupMenuObjType.
function PopupMenuObjType_Callback(hObject, eventdata, handles)
% hObject    handle to PopupMenuObjType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupMenuObjType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupMenuObjType


% --- Executes during object creation, after setting all properties.
function PopupMenuObjType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupMenuObjType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditClusterCutoff_Callback(hObject, eventdata, handles)
% hObject    handle to EditClusterCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditClusterCutoff as text
%        str2double(get(hObject,'String')) returns contents of EditClusterCutoff as a double


% --- Executes during object creation, after setting all properties.
function EditClusterCutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditClusterCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SliderClusterCutoff_Callback(hObject, eventdata, handles)
% hObject    handle to SliderClusterCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
donut_sliderfunc(hObject);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderClusterCutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderClusterCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
