############################################################
# Dockerfile to build OmniSensr
# Based on Jessie
############################################################

FROM resin/raspberrypi2-debian:jessie

## Install mjpg-streamer

RUN echo "Getting Dependencies..."
RUN apt-get update && apt-get install -y libjpeg8-dev imagemagick cmake && \
	ln -s /usr/include/linux/videodev2.h /usr/include/linux/videodev.h

RUN echo "Creating download folder"
RUN mkdir download; cd download

RUN echo "Downloading and extracting mjpg-streamer"
RUN wget https://github.com/jacksonliam/mjpg-streamer/archive/master.zip
RUN mv master.zip mjpg-streamer.zip
RUN unzip mjpg-streamer.zip
RUN mv mjpg-streamer-master/mjpg-streamer-experimental mjpg-streamer
RUN rm -r mjpg-streamer-master; cd mjpg-streamer

RUN echo "make-ing mjpg streamer"
RUN make

RUN echo "copying out binaries"
RUN cp mjpg_streamer /usr/local/bin
RUN cp *.so /usr/local/lib
RUN cp -R www /usr/local

RUN echo "adding to load lib path"
RUN echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib' | tee -a /etc/bash.bashrc
RUN echo '/usr/local/lib' | tee /etc/ld.solconf.d/OmniSensr.conf

echo "to keep Gary happy - removing src code of mjpg-streamer"
RUN cd ..
RUN rm -rf mjpg-streamer
RUN rm -rf mjpg-streamer.zip
RUN cd ..
RUN rmdir download

RUN echo "reolading bashrc"
RUN source /etc/bash.bashrc

RUN echo "reloading libraries"
RUN ldconfig

COPY /home/cstewart/app/scripts/usr-local-script/start_cam.sh /usr/local/script

CMD /usr/local/script/start_cam.sh

