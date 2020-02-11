import cv2
import numpy as np 

cap = cv2.VideoCapture(0)

while True:
	_, frame = cap.read()
	rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

	lower_green = np.array([110, 110, 110])
	upper_green = np.array([255, 255, 255])

	green_mask = cv2.inRange(rgb, lower_green, upper_green)

	(contours,_) = cv2.findContours(green_mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

	for contour in contours: 		
		area = cv2.contourArea(contour)

		if(area > 20):
			x,y,w,h = cv2.boundingRect(contour)
			frame = cv2.rectangle(frame, (x,y),(x+w,y+h),(0,0,255),10)

	cv2.imshow("tracking", frame)

	if cv2.waitKey(10) & 0XFF == ord('q'):
		break

cv2.destroyAllWindows()
cap.release()
