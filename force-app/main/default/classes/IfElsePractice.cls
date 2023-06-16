public class IfElsePractice {

    public void printSign(Integer num) {
        if(num < 0) {
            System.debug('negative');
        } else if(num > 0) {
            System.debug('positive');
        } else {
            System.debug('zero');
        }
    }

    public void hasNLength(String input, Integer n) {
        if(input.length() >= n){
            System.debug('valid');
        } else {
            System.debug('invalid');
        }
    }

    public Boolean hasExactLength(String input, Integer n) {
        if(input.length() == n) {
            return true;
        } else {
            return false;
        }
    }

    public Integer maximumNumber(Integer number1, Integer number2) {
        if(number1 >= number2) {
            return number1;
        } else {
            return number2;
        }
    }

    public Integer maximumNumber(Integer number1, Integer number2, Integer number3) {
        if(number1 >= number2 && number1 >= number3) {
            return number1;
        } else if(number2 >= number1 && number2 >= number3) {
            return number2;
        } else  {
            return number3;
        } 
    }

    public Boolean isEven(Integer num) {
        if(Math.mod(num, 2) == 0) {
            return true;
        } else {
            return false;
        }
    }

    public Decimal convertTemperature(Decimal temperature, String unit) {
        if(unit == 'C') {
            return ((temperature * 9 / 5) + 32);
        } else if(unit == 'F') {
            return ((temperature - 32) * 5 / 9);
        } else {
            return 0;
        }
    }
}