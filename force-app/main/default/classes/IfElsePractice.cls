public class IfElsePractice {

    public void printSign(Integer num) {
        String sign = 'zero';

        if(num < 0) {
            sign = 'negative';
        } else if(num > 0) {
            sign = 'positive';
        } 

        System.debug(sign);
    }

    public void hasNLength(String input, Integer n) {        
        System.debug(input.length() >= n ? 'valid' : 'invalid')
    }

    public Boolean hasExactLength(String input, Integer n) {
        return input.length() == n;
    }

    public Integer maximumNumber(Integer number1, Integer number2) {
        return number1 >= number2 ? number1 : number2;
    }

    public Integer maximumNumber_Math(Integer number1, Integer number2) {
        return Math.max(number1, number2);
    }

    public Integer maximumNumber(Integer number1, Integer number2, Integer number3) {
        return Math.max(number1, Math.max(number2, number3));
    }

    public Boolean isEven(Integer num) {
        return Math.mod(num, 2) == 0;
    }

    public Decimal convertTemperature(Decimal temperature, String unit) {
        Decimal convertedTemperature = 0.0;
        
        if(unit == 'C') {
            convertedTemperature = ((temperature * 9 / 5) + 32);
        } else if(unit == 'F') {
            convertedTemperature = ((temperature - 32) * 5 / 9);
        } 

        return convertedTemperature;
    }
}