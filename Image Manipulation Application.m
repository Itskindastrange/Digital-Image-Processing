function gui 
    img = [];
    imgInfo = [];
    compressedImgInfo = [];  
    compressionRatio = 0;
    f = figure('Position', [500 100 500 600], 'MenuBar', 'none', 'Name', 'Image Processing', 'NumberTitle', 'off');
    axesHandle = axes('Parent', f, 'Position', [0.1, 0.35, 0.8, 0.6]);
    uicontrol('Style', 'pushbutton', 'Position', [150 180 100 30], 'String', 'Open Image', 'Callback', @openImage);
    uicontrol('Style', 'pushbutton', 'Position', [150 130 100 30], 'String', 'Image Details', 'Callback', @displayImageDetails);
    uicontrol('Style', 'pushbutton', 'Position', [150 80 100 30], 'String', 'Image Operations', 'Callback', @openOperationsWindow);
    uicontrol('Style', 'text', 'Position', [20 140 100 20], 'String', 'Save As:');
    formatPopup = uicontrol('Style', 'popupmenu', 'Position', [20 100 100 20], 'String', {'Select Format', '.jpg', '.png', '.bmp', '.tiff'}, 'Callback', @saveImage);

    function resizeAxesForImage(imageSize)
        aspectRatio = imageSize(2) / imageSize(1);
        axWidth = 0.8; 
        axHeight = axWidth / aspectRatio; 
        if axHeight > 0.6
            axHeight = 0.6;
            axWidth = axHeight * aspectRatio;
        end
        set(axesHandle, 'Position', [(1 - axWidth) / 2, 0.35, axWidth, axHeight]);
    end
    
    function openImage(~, ~)
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.tiff', 'Image Files (*.jpg, *.png, *.bmp, *.tiff)'}, 'Select an Image');
        if isequal(file, 0)
            disp('No file selected');
        else
            fullFile = fullfile(path, file);
            img = imread(fullFile);
            imgInfo = imfinfo(fullFile);
            imshow(img, 'Parent', axesHandle);
            resizeAxesForImage(size(img));
            disp('File selected');
        end
    end

    function displayImageDetails(~, ~)
        if isempty(img)
            errordlg('Please open an image first.', 'No Image');
            return;
        end
        
        height = imgInfo.Height;
        width = imgInfo.Width;
        format = imgInfo.Format;
        originalFileSize = imgInfo.FileSize / 1024;
        if ~isempty(compressedImgInfo)
            compressedFileSize = compressedImgInfo.bytes / 1024;
            compressionRatio = originalFileSize / compressedFileSize;
        else
            compressedFileSize = originalFileSize;
            compressionRatio = 0;
        end
        msgbox({
            ['Height: ', num2str(height), ' pixels'], ...
            ['Width: ', num2str(width), ' pixels'], ...
            ['Format: ', format], ...
            ['Original File Size: ', num2str(originalFileSize, '%.2f'), ' KB'], ...
            ['Compressed File Size: ', num2str(compressedFileSize, '%.2f'), ' KB'], ...
            ['Compression Ratio: ', num2str(compressionRatio, '%.2f')]
        }, 'Image Details');
    end

    function openOperationsWindow(~, ~)
        operationsWindow();
    end
    
    function saveImage(~, ~)
        if isempty(img)
            errordlg('Please open an image first.', 'No Image');
            return;
        end
        
        formats = {'.jpg', '.png', '.bmp', '.tiff'};
        selectedFormat = formats{get(formatPopup, 'Value')};
        if strcmp(selectedFormat, 'Select Format')
            errordlg('Please select a format first.', 'No Format Selected');
            return;
        end
        
        [file, path] = uiputfile(['*', selectedFormat], 'Save Image As');
        if isequal(file, 0)
            disp('User canceled save.');
        else
            fullFile = fullfile(path, file);
            imwrite(img, fullFile);
            disp(['Image saved as: ', fullFile]);
        end
    end

    function operationsWindow()
        opFig = figure('Position', [800 100 400 400], 'MenuBar', 'none', 'Name', 'Image Operations', 'NumberTitle', 'off');
        uicontrol('Style', 'pushbutton', 'Position', [20 340 100 30], 'String', 'Convert to B/W', 'Callback', @convertToBw);
        uicontrol('Style', 'pushbutton', 'Position', [20 290 100 30], 'String', 'Crop Image', 'Callback', @cropImage);
        uicontrol('Style', 'pushbutton', 'Position', [20 240 100 30], 'String', 'Resize Image', 'Callback', @resizeImage);
        uicontrol('Style', 'pushbutton', 'Position', [20 190 100 30], 'String', 'Flip Vertically', 'Callback', @flipVertically);
        uicontrol('Style', 'pushbutton', 'Position', [20 140 100 30], 'String', 'Flip Horizontally', 'Callback', @flipHorizontally);
        uicontrol('Style', 'pushbutton', 'Position', [20 90 100 30], 'String', 'Combine Images', 'Callback', @combineImages);
        uicontrol('Style', 'pushbutton', 'Position', [20 40 100 30], 'String', 'Compress Image', 'Callback', @compressImage);

        function convertToBw(~, ~)
            if isempty(img)
                errordlg('Please open an image first.', 'No Image');
                return;
            end
            if size(img, 3) == 3
                grayImg = rgb2gray(img);
            else
                grayImg = img;
            end
            originalImg = img;
            threshold = 128;
            threshFig = figure('Position', [800 100 400 200], 'MenuBar', 'none', 'Name', 'Threshold Adjustment', 'NumberTitle', 'off');
            threshSlider = uicontrol('Style', 'slider', 'Position', [20 100 360 20], 'Min', 0, 'Max', 255, 'Value', threshold, 'Callback', @adjustThreshold);
            threshValueText = uicontrol('Style', 'text', 'Position', [170 70 60 20], 'String', num2str(threshold));
            uicontrol('Style', 'text', 'Position', [20 130 360 20], 'String', 'Adjust Threshold');
            uicontrol('Style', 'pushbutton', 'Position', [70 30 100 30], 'String', 'Apply', 'Callback', @applyThreshold);
            uicontrol('Style', 'pushbutton', 'Position', [230 30 100 30], 'String', 'Cancel', 'Callback', @cancelThreshold);
            bwImg = imbinarize(grayImg, threshold / 255);
            imshow(bwImg, 'Parent', axesHandle);
            resizeAxesForImage(size(bwImg));
            function adjustThreshold(hObject, ~)
                threshold = get(hObject, 'Value');  
                set(threshValueText, 'String', num2str(round(threshold)));
                bwImg = imbinarize(grayImg, threshold / 255);  
                imshow(bwImg, 'Parent', axesHandle);
                resizeAxesForImage(size(bwImg));
            end
            function applyThreshold(~, ~)
                img = bwImg;
                close(threshFig);
            end
            function cancelThreshold(~, ~)
                img = originalImg;
                imshow(img, 'Parent', axesHandle);
                resizeAxesForImage(size(img));
                close(threshFig);
            end
        end
        
        function cropImage(~, ~)
            if isempty(img)
                errordlg('Please open an image first.', 'No Image');
                return;
            end
            img = imcrop(img);
            imshow(img, 'Parent', axesHandle);
            resizeAxesForImage(size(img));
        end
        
        function resizeImage(~, ~)
            if isempty(img)
                errordlg('Please open an image first.', 'No Image');
                return;
            end
            prompt = {'Enter width:', 'Enter height:'};
            dims = inputdlg(prompt, 'Resize Image', 1, {'300', '300'});
            if ~isempty(dims)
                newWidth = str2double(dims{1});
                newHeight = str2double(dims{2});
                img = imresize(img, [newHeight newWidth]);
                imshow(img, 'Parent', axesHandle);
                resizeAxesForImage(size(img));
            end
        end
        
        function flipVertically(~, ~)
            if isempty(img)
                errordlg('Please open an image first.', 'No Image');
                return;
            end
            img = flipud(img);
            imshow(img, 'Parent', axesHandle);
            resizeAxesForImage(size(img));
        end
        
        function flipHorizontally(~, ~)
            if isempty(img)
                errordlg('Please open an image first.', 'No Image');
                return;
            end
            img = fliplr(img);
            imshow(img, 'Parent', axesHandle);
            resizeAxesForImage(size(img));
        end
        
        function combineImages(~, ~)
            [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.tiff', 'Image Files (*.jpg, *.png, *.bmp, *.tiff)'}, 'Select a second Image');
            if isequal(file, 0)
                disp('No second image selected');
                return;
            end
            secondImg = imread(fullfile(path, file));
            combineMethod = questdlg('How do you want to combine the images?', 'Combine Images', 'Side-by-Side', 'Overlay', 'Side-by-Side');
            switch combineMethod
                case 'Side-by-Side'
                    secondImg = imresize(secondImg, [size(img, 1), NaN]); 
                    img = cat(2, img, secondImg); 
                case 'Overlay'
                    secondImg = imresize(secondImg, [size(img, 1), size(img, 2)]); 
                    img = imfuse(img, secondImg, 'blend'); 
            end
            imshow(img, 'Parent', axesHandle);
            resizeAxesForImage(size(img));
        end
        
        function compressImage(~, ~)
            if isempty(img)
                errordlg('Please open an image first.', 'No Image');
                return;
            end
            compressionLevel = inputdlg('Enter compression level (0-100):', 'Image Compression', [1 50], {'70'});
            if isempty(compressionLevel)
                return;
            end
            compressionLevel = str2double(compressionLevel{1});
            compressionLevel = max(0, min(compressionLevel, 100));
            tempFile = [tempname, '.jpg'];
            imwrite(img, tempFile, 'jpg', 'Quality', compressionLevel);
            fileInfo = dir(tempFile);
            compressedImgInfo.bytes = fileInfo.bytes;
            compressedFileSize = compressedImgInfo.bytes / 1024;
            compressedImg = imread(tempFile);
            imshow(compressedImg, 'Parent', axesHandle);
            resizeAxesForImage(size(compressedImg));
            %delete(tempFile);
            compressionRatio = imgInfo.FileSize / compressedImgInfo.bytes;
        end
    end
end
