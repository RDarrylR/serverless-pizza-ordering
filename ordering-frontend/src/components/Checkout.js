import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useCart } from '../context/CartContext';
import { TopicClient, TopicConfigurations, CredentialProvider } from '@gomomento/sdk-web'
import '../common.css';

const Checkout = ({ onPurchaseComplete, isCheckoutDisabled, onOrderStatusUpdate }) => {
  const navigate = useNavigate();
  const { cart, clearCart, isProfileComplete, profile } = useCart();
  const [orderType, setOrderType] = useState('delivery'); // Default to delivery

  const total = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const isCartEmpty = cart.length === 0;
  const profileComplete = isProfileComplete();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (isCheckoutDisabled) {
      alert("Please close the current order progress before starting a new checkout.");
      return;
    }
    if (!profileComplete) {
      alert("Please complete your profile before checking out.");
      navigate('/profile');
      return;
    }

    // Create the order details JSON object
    const orderDetails = {
      customer: {
        name: profile.name,
        address: profile.address,
        phone: profile.phone
      },
      items: cart.map(item => ({
        productName: item.name,
        productId: item.id,
        quantity: item.quantity,
        totalPrice: item.price * item.quantity
      })),
      totalAmount: total,
      orderType: orderType  // Add this line to include the orderType
    };

    // Output the order details to the console
    console.log(JSON.stringify(orderDetails, null, 2));

    try {
      const response = await fetch(process.env.REACT_APP_ORDERING_API, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(orderDetails),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      console.log('Order submitted successfully:', data);

      try {
        console.log('Init Momento topics: START')

        const topicClient = new TopicClient({
          configuration: TopicConfigurations.Browser.latest(),
          credentialProvider: CredentialProvider.fromString({
            apiKey: data.token
          })
        })      
        
        console.log("topicClient=", topicClient)

        const topic = `${process.env.REACT_APP_MOMENTTO_TOPIC}${data.orderId}`
        console.log("topic=", topic)
      
        console.log('Init Momento topics: DONE')
        console.log('Subscribing to cache/topic', process.env.REACT_APP_MOMENTTO_CACHE, topic)
    
        await topicClient.subscribe(process.env.REACT_APP_MOMENTTO_CACHE, topic, {
          onItem: (item => {
            console.log('Received item:', item.value());
            try {
              const status = JSON.parse(item.value());
              console.log("status=", status.State)
              onOrderStatusUpdate(status);
            } catch (error) {
              console.error('Error parsing status update:', error);
              onOrderStatusUpdate({ message: item.value() });
            }
          }),
          onError: (error) => {
            alert(`Error subscribing to Momento topic: ${error.message}`)
          }
        })

      } catch (error) {
        console.error('Failed to initialize API connection:', error);
      }   
         
      // Assuming the checkout was successful
      clearCart(); // Clear the cart
      onPurchaseComplete(orderType); // Pass the orderType to the parent component
      navigate('/');  // Redirect to home page or order confirmation page
    } catch (error) {
      console.error('There was a problem with the order submission:', error);
      alert('There was a problem submitting your order. Please try again.');
    }
  };

  return (
    <div className="checkout-container">
      <h2>Checkout</h2>
      {isCheckoutDisabled ? (
        <p>Checkout is currently disabled. Please close the order progress to start a new checkout.</p>
      ) : isCartEmpty ? (
        <p>Your cart is empty. Add some items before checking out.</p>
      ) : (
        <>
          <div className="order-type-selector">
            <h3>Order Type:</h3>
            <label>
              <input
                type="radio"
                value="delivery"
                checked={orderType === 'delivery'}
                onChange={(e) => setOrderType(e.target.value)}
              />
              Delivery
            </label>
            <label>
              <input
                type="radio"
                value="pickup"
                checked={orderType === 'pickup'}
                onChange={(e) => setOrderType(e.target.value)}
              />
              Pickup
            </label>
          </div>
          {cart.map(item => (
            <div key={item.id} className="checkout-item">
              <Link to={`/product/${item.id}`} className="checkout-item-name">{item.name}</Link>
              <span>Quantity: {item.quantity}</span>
              <span>${(item.price * item.quantity).toFixed(2)}</span>
            </div>
          ))}
          <div className="checkout-total">
            <strong>Total: ${total.toFixed(2)}</strong>
          </div>
          {!profileComplete && (
            <p className="profile-warning">Please complete your profile before checking out. <Link to="/profile">Go to Profile</Link></p>
          )}
          <button 
            className="checkout-button"
            onClick={handleSubmit}
            disabled={isCheckoutDisabled || !profileComplete}
          >
            Complete Purchase
          </button>
        </>
      )}
      <Link to="/cart" className="back-to-cart">Back to Cart</Link>
    </div>
  );
};

export default Checkout;