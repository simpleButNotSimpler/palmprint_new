function [image, direction_code] = edgeresponse(im_raw)
%cmfrat filters 0, 20, 40, 60, 80, 100, 120, 140, 160        
for t=1:9
    idx = (t-1)*20;
    im(t).val = imfilter(im_raw, cmfrat(11, 11, idx));
end

%combined image
[image, direction_code] = maxresponse(im);
image = imadjust(image, stretchlim(image), [0; 1]);


function mat = cmfrat(row, col, angle)
    row = row + 4;
    col = col + 4;
    mat = zeros(row, col);
    
    m = -tand(angle);
    a = round(col / 2);
    b = round(row / 2);
    
    if (angle >= 0 && angle <= 45) || (angle > 135 && angle <= 180)
        for x=col - 2:-1:3
            y = round(m*(x - a) + b);
%             mat([y-1, y, y+1], x) = -4/14;
%             mat([y-3, y-2, y+2, y+3], x) = 3/14;
              mat([y-1, y, y+1], x) = -1/33;
              mat([y-3, y-2, y+2, y+3], x) = 1/44;
        end
        
    elseif angle > 45 && angle <= 135
        for y=row - 2:-1:3
            x = round((y - b)/m + a);
            mat(y, [x-1, x, x+1]) = -1/33;
            mat(y, [x-3, x-2, x+2, x+3]) = 1/44;
        end
    end
    
function [image, direction_code] = maxresponse(im)
[row, col] = size(im(1).val);
image = im(1).val;
direction_code = uint8(zeros(row, col));

for t=2:9
    direction_code(im(t).val > image) = (t-1)*20;
    image = max(image, im(t).val);
end
