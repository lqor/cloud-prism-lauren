public class Radio {

    public Decimal frequency;
    public String radioType;
    public Boolean isOn;
    
    public Radio(){
        frequency = 135.5;//comment
        radioType = 'Sony DSX-A110U';
        isOn = true;
    }
    
    public Radio(String radioType){
        frequency = 135.5;
        this.radioType = radioType;
        isOn = true;
    }
    
    public Decimal nextChannel(){
        return frequency += 10;
    }
    
}