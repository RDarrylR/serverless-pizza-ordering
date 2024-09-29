import React from 'react';
import { Link } from 'react-router-dom';
import { useCart } from '../context/CartContext';
import '../common.css';

function Header() {
  const { cart } = useCart();

  return (
    <header className="header">
      <h1 className="title">
        <Link to="/" className="link">Cloud Pizzeria</Link>
      </h1>
      <nav>
        <ul className="nav-list">
          <li className="nav-item"><Link to="/" className="link">Home</Link></li>
          <li className="nav-item"><Link to="/products" className="link">Products</Link></li>
          <li className="nav-item"><Link to="/profile" className="link">Profile</Link></li>
          <li className="nav-item">
            <Link to="/cart" className="link">
              Cart ({cart.reduce((sum, item) => sum + item.quantity, 0)})
            </Link>
          </li>
          <li className="nav-item"><Link to="/checkout" className="link">Checkout</Link></li>
        </ul>
      </nav>
    </header>
  );
}

export default Header;