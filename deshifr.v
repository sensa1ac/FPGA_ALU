module Keyboard_PS2
(
input wire clk, // вход синхронизации
input wire data, //вход данных
output reg [7:0] led, //выход для отображения полученных данных
output reg [6:0] HEX7, HEX0, HEX1//семисегменты
);
reg [7:0] data_curr; //регистр для текущего байта
reg [7:0] data_pre; //регистр для предыдущего байта
reg [3:0] b; //регистр для подсчёта номера бита
reg flag; // флаг окончания сообщения

reg a; //вспомогательный рег для раскладки

initial // инициация регистров
begin
	b<=4'h1;
	flag<=1'b0;
	data_curr<=8'hf0;
	data_pre<=8'hf0;
	led<=8'hf0;
	
	a<=1'b0;
end


always @(negedge clk) //при заднем фронте импульса
begin
	case(b) //в значимости от номера бита
		data_curr[0]<=data; //запись в нужную ячейку
		data_curr[1]<=data; //запись в нужную ячейку
		data_curr[2]<=data; //запись в нужную ячейку
		data_curr[3]<=data; //запись в нужную ячейку
		data_curr[4]<=data; //запись в нужную ячейку
		data_curr[5]<=data; //запись в нужную ячейку
		data_curr[6]<=data; //запись в нужную ячейку
		data_curr[7]<=data; //запись в нужную ячейку
		flag<=1'b1; //подымаем флаг окончания
		flag<=1'b0; //опускаем флаг окончания
	endcase
if (b<=10) //считаем номер бита
	b<=b+1;
else if (b==11) //сбрасываем номер бита
	b<=1;
end


always@(posedge flag) //когда передача закончилась
begin
	if(data_curr==8'hf0) //если это специальный код
		led<=data_pre; //то выводим предыдущий байт
	else
		data_pre<=data_curr; //сохраняем предыдущий байт
end


always@(posedge clk) //запись в семисегмент  
begin
	HEX7 = ~7'b0000000;
	HEX01 = ~7'b11011101110011; //РУ-раскладка автоматом
	
	case (data_curr) //клавиш 0-9
		8'b01000101: HEX7 = ~7'b0111111;//0
		8'b00010110: HEX7 = ~7'b0000110;//1
		8'b00011110: HEX7 = ~7'b1011011;//2
		8'b00100110: HEX7 = ~7'b1001111;//3
		8'b00100101: HEX7 = ~7'b1100110;//4
		8'b00101110: HEX7 = ~7'b1101101;//5
		8'b00110110: HEX7 = ~7'b1111101;//6
		8'b00111101: HEX7 = ~7'b0000111;//7
		8'b00111110: HEX7 = ~7'b1111111;//8
		8'b01000110: HEX7 = ~7'b1101111;//9	
	endcase
	
	if (data_pre==8'b00010010 & data_curr==8'b00010001)
			a=1; // надо изменить раскладку
		else 
			a=0; // раскладка прежняя
			
	if (a==0)	
		HEX01 = ~7'b11011101110011; //РУ
	else 
	if (HEX01 == ~7'b11011101110011) //ру
		HEX01 = ~7'b10101001111001; //En
	else
		HEX01 = ~7'b11011101110011; //РУ
	
end



endmodule