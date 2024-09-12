imshow(year2000)
title("Year 2000")


year2016 = imread("year2016.jpg");
imshowpair(year2000,year2016,"montage")
title("2016 vs 2000")


gray2016 = im2gray(year2016);
imshow(gray2016)
%tilte("Gray Scaled 2016 image")

imhist(gray2016);

adj2016 = imadjust(gray2016);
imhist(gray2016)
title("Adjusted hist")

imshowpair(gray2016,adj2016,'montage')
title("Gray scale vs Adjusted GS")

year2004 =imread("year2004.jpg")
gray2004 = im2gray(year2004);
%imshow(gray2004)
%tilte("Gray Scaled 2004 image")

%imhist(gray2004);

adj2004 = imadjust(gray2004);
