class Stack { 
  
    constructor() 
    { 
        this.items = []; 
    } 
  
  	push(element) {
  		if(Number.isInteger(element) && parseInt(element) >= 0) {
  			this.items.add(0, element);
  		} else {
  			console.log("Please enter numbers only");
  		}
  	}

	pop() {
		if(this.items.length > 0) {
			var element = this.items.remove();
			console.log("The pop element is ", element[0]);
			
		} else {
			console.log("The stack is empty");
		}
	} 
} 

Array.prototype.add = function (index,item) {
    this.splice(index, 0,item );
};

Array.prototype.remove = function () {
    return this.splice(0,1);
};