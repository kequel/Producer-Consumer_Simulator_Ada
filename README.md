# Producer-Consumer Simulator in Ada
This is a Producer-Consumer Simulator written in Ada, developed as part of the Programming Languages course in our third semester at Gdańsk University of Technology.

## Authors
- Martyna Borkowska [GitHub](https://github.com/martynkaqhe)
- Karolina Glaza [GitHub](https://github.com/kequel)

### Version
Current version: 1.0

## Description
The new gaming boxes are being sold as the new game has been realesed. The clients are two big electronics shop in Poland, and the producers and buffer try to give them what they need. They randomly choose from assemblies:

`Basic` includes: Keychain, Socks, MousePad

`Deluxe` includes: Keychain, Socks, MousePad Deluxe

`Premium Deluxe` includes: Keychain, Socks, T-Shirt, MousePad Deluxe

The program ensures proper synchronization between producers and consumers using Ada’s tasking and protected types.

Both producers and consumers run concurrently, simulating a real-time production.

### Producers
1) Each producer generates a specific type of product and places it in the storage buffer.
2) Multiple producers work concurrently, each responsible for one type of product.
3) When producers have more than 3 items in storage they go on vacation.
4) When producer has item in his personal storage, production time is cut only to delivery time.
   
### Consumers
1) Consumers order random assemblies.
2) If the required items are not available, the consumer waits until the storage contains enough resources to continue assembly.
3) If he waits for too long, he loses intrest.
4) If customers' last transaction was a success, the consumption time is shorter, as he is more eager to buy another one.
   
### Buffer
1) The shared buffer where producers deposit items and consumers retrieve them.
2) Only one task can access or modify the storage at a time.
3) Has its limits to prevent deadlocks.
4) If has a high goodness of heart, gives half of its products away as a Noble Gift.

## Example of Output 
`P: On vacation went producer Keychain  `                      

`B: Delivered assembly Premium Deluxe  ` 

`C: MEDIA EXPERT takes assembly Premium Deluxe  `

`|   Storage contents:  1 Keychain `                     

`|   Storage contents:  4 Socks    `                     

`|   Storage contents:  2 T-shirt    `                   

`|   Storage contents:  3 Mousepad  `                    

`|   Storage contents:  3 Mousepad Deluxe     `          

`|   Number of products in storage:  19`

`B: Nobel gift accepted with charity level  9`

`|   Storage contents:  0 Keychain    `                  

`|   Storage contents:  2 Socks     `                    

`|   Storage contents:  1 T-shirt   `                    

`|   Storage contents:  1 Mousepad  `                    

`|   Storage contents:  1 Mousepad Deluxe  `             

`|   Number of products in storage:  18  `

`P: Produced product T-shirt  `

`B: Accepted product T-shirt  `
