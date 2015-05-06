function jacobianImage(J, colsize)

imJ = zeros(colsize, colsize, 6);

for i=1:6
    imJ(:,:,i) = reshape(J(:,i), colsize, colsize);
    imwrite(imJ(:,:,i), sprintf('J%d.png', i));
end