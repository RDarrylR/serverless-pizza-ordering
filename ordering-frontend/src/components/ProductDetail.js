import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { useCart } from '../context/CartContext';
import '../common.css';

// Import the products array from ProductList.js
import { products } from './ProductList';

function ProductDetail() {
  const { id } = useParams();
  const { addToCart } = useCart();

  // Find the product with the matching id
  const product = products.find(p => p.id === parseInt(id));

  if (!product) {
    return <div>Product not found</div>;
  }

  // Additional details for each pizza
  const additionalDetails = {
    5678: "Our Margherita Pizza is a classic Italian favorite. Made with San Marzano tomatoes, fresh mozzarella, and aromatic basil leaves, it's a simple yet delicious option that captures the essence of Neapolitan pizza.",
    9012: "The Pepperoni Pizza is an American classic. Topped generously with spicy pepperoni slices and melted mozzarella cheese, it's a crowd-pleaser that's perfect for any occasion.",
    3456: "Our Vegetarian Pizza is a colorful medley of fresh vegetables. Topped with bell peppers, onions, mushrooms, olives, and tomatoes, it's a delightful option for veggie lovers.",
    7890: "The Hawaiian Pizza combines sweet and savory flavors. Topped with ham and pineapple chunks, it's a controversial yet beloved pizza that's sure to spark conversation.",
    2345: "Our BBQ Chicken Pizza is a tangy delight. Topped with grilled chicken, red onions, and a smoky BBQ sauce, it's a flavorful twist on traditional pizza.",
    6789: "The Supreme Pizza is loaded with toppings. It features a mix of meats including pepperoni and sausage, along with vegetables like bell peppers, onions, and olives. It's the perfect choice for those who want it all!",
    1234: "Our Mushroom Pizza is a fungi lover's dream. Topped with a variety of mushrooms including portobello, shiitake, and button mushrooms, it's a rich and earthy option.",
    4567: "The Buffalo Chicken Pizza brings the heat! Topped with spicy buffalo chicken, red onions, and a drizzle of ranch dressing, it's a bold and flavorful choice."
  };

  return (
    <div className="product-detail-container">
      <Link to="/products" className="back-link">Back to Products</Link>
      <div className="product-detail">
        <img src={product.image} alt={product.name} className="product-image" />
        <div className="product-info">
          <h2>{product.name}</h2>
          <p>{product.description}</p>
          <p className="product-price">${product.price.toFixed(2)}</p>
          <h3>Additional Details:</h3>
          <p>{additionalDetails[product.id]}</p>
          <h3>Ingredients:</h3>
          <p>Pizza dough, tomato sauce, mozzarella cheese, {product.name.toLowerCase().includes('vegetarian') ? 'assorted vegetables' : 'and various toppings'}.</p>
          <h3>Nutritional Information:</h3>
          <p>Calories: Approximately 250-300 per slice (varies based on toppings)</p>
          <button onClick={() => addToCart(product)} className="add-to-cart-button">Add to Cart</button>
        </div>
      </div>
    </div>
  );
}

export default ProductDetail;