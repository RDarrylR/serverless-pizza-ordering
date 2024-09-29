import React from 'react';
import { Link } from 'react-router-dom';
import { useCart } from '../context/CartContext';
import '../common.css';

export const products = [
  { id: 5678, name: 'Margherita Pizza', price: 12.99, image: 'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=300&h=300&fit=crop', description: 'Classic pizza with tomato sauce, mozzarella, and basil' },
  { id: 9012, name: 'Pepperoni Pizza', price: 14.99, image: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=300&h=300&fit=crop', description: 'Traditional pizza topped with pepperoni slices' },
  { id: 3456, name: 'Vegetarian Pizza', price: 13.99, image: 'https://images.unsplash.com/photo-1511689660979-10d2b1aada49?w=300&h=300&fit=crop', description: 'Loaded with assorted vegetables and cheese' },
  { id: 7890, name: 'Hawaiian Pizza', price: 15.99, image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=300&h=300&fit=crop', description: 'Ham and pineapple pizza for a sweet and savory taste' },
  { id: 2345, name: 'BBQ Chicken Pizza', price: 16.99, image: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300&h=300&fit=crop', description: 'Topped with BBQ sauce, chicken, and red onions' },
  { id: 6789, name: 'Supreme Pizza', price: 17.99, image: 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=300&h=300&fit=crop', description: 'Loaded with various meats and vegetables' },
  { id: 1234, name: 'Mushroom Pizza', price: 13.99, image: 'https://images.unsplash.com/photo-1590947132387-155cc02f3212?w=300&h=300&fit=crop', description: 'For mushroom lovers, topped with various mushroom types' },
  { id: 4567, name: 'Buffalo Chicken Pizza', price: 16.99, image: 'https://images.unsplash.com/photo-1571066811602-716837d681de?w=300&h=300&fit=crop', description: 'Spicy buffalo chicken pizza with blue cheese' },
];

function ProductList() {
  const { addToCart } = useCart();

  return (
    <div className="product-list">
      <h2>Our Pizza Menu</h2>
      <div className="product-grid">
        {products.map(product => (
          <div key={product.id} className="product">
            <img src={product.image} alt={product.name} className="product-image" />
            <div className="product-info">
              <h3>{product.name}</h3>
              <p>{product.description}</p>
              <p className="product-price">${product.price.toFixed(2)}</p>
              <div className="product-actions">
                <Link to={`/product/${product.id}`} className="view-details">View Details</Link>
                <button onClick={() => addToCart(product)} className="add-to-cart">Add to Cart</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default ProductList;