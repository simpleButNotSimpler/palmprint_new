function score = palmcode_diff_weights_fused(im1, im2, palm_im1, palm_im2)
%take two palmcode and two cannys as input and output the difference of their histogram
    
    siz1 = size(im1);
    bsize = floor(siz1(1)/7);
    blocks = 1:bsize:siz1(1)+1;
    blocks(end) = siz1(1)+1;
    
    %fuse the palm images
    palm_im1(palm_im2 > 0) = 255;
    
    weights = ones(siz1);
    weights(palm_im1 > 0) = 2;
    score = histo_diff(im1, im2, weights, blocks);
end

function score = histo_diff(im1, im2, weights, range)
   len = numel(range) - 1;
   score = 0;
   
   for m=1:len
       for n=1:len
          block1 = im1(range(m):range(m+1)-1, range(n):range(n+1)-1);
          block_weights = weights(range(m):range(m+1)-1, range(n):range(n+1)-1);
          histo_vector1 = code_block_histo(block1, block_weights);

          block2 = im2(range(m):range(m+1)-1, range(n):range(n+1)-1);
          block_weights = weights(range(m):range(m+1)-1, range(n):range(n+1)-1);
          histo_vector2 = code_block_histo(block2, block_weights);
          
          score = score + sum(abs(histo_vector1 - histo_vector2)) / sum(histo_vector1);
       end       
   end
   
   score = score / (len*len);
end

function hv = code_block_histo(im, block_weights)
   hv = zeros(1, 9);
   [row, col] = size(im);
   
   for t=1:row
       for k=1:col
           idx = (im(t,k)/20) + 1;
           hv(idx) =  hv(idx) + block_weights(t,k);
       end
   end
end