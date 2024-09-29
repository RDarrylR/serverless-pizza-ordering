import React from 'react';
import { Link } from 'react-router-dom';
import { useCart } from '../context/CartContext';
import '../common.css';

function Cart() {
  const { cart, removeFromCart, increaseQuantity, decreaseQuantity } = useCart();

  const total = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);

  if (cart.length === 0) {
    return (
      <div className="cart-container">
        <h2>Your Cart</h2>
        <p>Your cart is empty.</p>
        <Link to="/products" className="continue-shopping">Continue Shopping</Link>
      </div>
    );
  }

  return (
    <div className="cart-container">
      <h2>Your Cart</h2>
      {cart.map(item => (
        <div key={item.id} className="cart-item">
          <Link to={`/product/${item.id}`} className="cart-item-name">{item.name}</Link>
          <div className="quantity-control">
            <button onClick={() => decreaseQuantity(item.id)} className="quantity-button">-</button>
            <span className="quantity">{item.quantity}</span>
            <button onClick={() => increaseQuantity(item.id)} className="quantity-button">+</button>
          </div>
          <span>${(item.price * item.quantity).toFixed(2)}</span>
          <button onClick={() => removeFromCart(item.id)} className="remove-button">Remove</button>
        </div>
      ))}
      <div className="cart-total">
        <strong>Total: ${total.toFixed(2)}</strong>
      </div>
      <Link to="/checkout" className="checkout-button">Proceed to Checkout</Link>
      <Link to="/products" className="continue-shopping">Continue Shopping</Link>
    </div>
  );
}

export default Cart;