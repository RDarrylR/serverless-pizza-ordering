import React from 'react';

function Product({ name, price }) {
  return (
    <div className="product">
      <h2>{name}</h2>
      <p>${price.toFixed(2)}</p>
      <button>Add to Cart</button>
    </div>
  );
}

export default Product;