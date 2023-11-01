%====================================================================%
%����ADC�ɼ�������Чλ��
ADC_DATA_WIDTH = 12;
%ADC�ɼ���ѹ��Χ��VOL_RANGE (V)
VOL_RANGE = 5;
%������(Hz)
SAMPLE_RATE = 50000000;
%ADC�ɼ���ѹ�ֱ��� LSB
LSB = VOL_RANGE*2/(2^ADC_DATA_WIDTH);
%====================================================================%

%��ȡ�ļ����ݣ�ת���ɲ�����ʾ
fileID = fopen('E:\MATLAB\SAVE2021_12_6_10-17-15.DAT');
src_data = fread(fileID);
fclose(fileID);
src_data_hex = src_data;

DATA_NUM = length(src_data_hex);
if(DATA_NUM > 1024*64)
  DATA_NUM = 1024*64;
end

voltage_code = 1:DATA_NUM/2;
voltage_code = voltage_code';
for i=1:1:DATA_NUM/2
  if src_data_hex(2*i-1)+src_data_hex(i*2)*256 > 2^(ADC_DATA_WIDTH-1)
    voltage_code(i) = src_data_hex(2*i-1)+src_data_hex(i*2)*256-2^ADC_DATA_WIDTH;
  else
    voltage_code(i) = src_data_hex(2*i-1)+src_data_hex(i*2)*256;
  end
end

%������ADC����ת��Ϊ��ѹֵ
voltage = voltage_code*LSB - LSB/2;
%ADC����ʱ��
sample_t = 1:DATA_NUM/2;
sample_t = sample_t';
for i=1:1:DATA_NUM/2
  sample_t(i) = 1000000/SAMPLE_RATE * i;
end
subplot(2,1,1)
plot(sample_t,voltage);
axis([0 1000000/SAMPLE_RATE*DATA_NUM/2 -VOL_RANGE VOL_RANGE]) 
title('ADC�ɼ���ѹ��ʾ')
xlabel('����ʱ��/(us)')
ylabel('��ѹ/(V)')
grid on

%FFT
L = DATA_NUM/2;
NFFT = 2^nextpow2(L);
voltage=voltage';
Y = fft(voltage,NFFT)/L;
Fs = SAMPLE_RATE;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(2,1,2)
plot(f,2*abs(Y(1:NFFT/2+1)));
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')