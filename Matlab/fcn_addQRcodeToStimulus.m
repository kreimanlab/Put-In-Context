function [updated] = fcn_addQRcodeToStimulus(qr, img)

    ScreenWidth = size(img,1);
    test_encode = cat(3, qr,qr,qr);
    test_encode = uint8(double(test_encode)*256);
    test_encode = imresize(test_encode, [ScreenWidth ScreenWidth]);
%     figure;
%     imshow(test_encode);
    updated= [test_encode img];
    
end

