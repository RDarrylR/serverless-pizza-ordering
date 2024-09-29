import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Header from './components/Header';
import Home from './components/Home';
import ProductList from './components/ProductList';
import ProductDetail from './components/ProductDetail';
import Cart from './components/Cart';
import Checkout from './components/Checkout';
import Profile from './components/Profile';
import OrderProgressBar from './components/OrderProgressBar';
import { CartProvider } from './context/CartContext';
import './common.css';
import './components/OrderProgressBar.css';

const deliverySteps = [
  'Starting to process order',
  'Order is in the oven',
  'Sending out delivery',
  'Order was delivered'
];

const pickupSteps = [
  'Starting to process order',
  'Order is in the oven',
  'Order is ready for pickup'
];

function App() {
  const [currentStep, setCurrentStep] = useState(0);
  const [lastUpdated, setLastUpdated] = useState(new Date());
  const [purchaseCompleted, setPurchaseCompleted] = useState(false);
  const [showCloseButton, setShowCloseButton] = useState(false);
  const [orderType, setOrderType] = useState('delivery'); // Default to delivery
  const [orderStatus, setOrderStatus] = useState('');

  useEffect(() => {
    document.title = "Cloud Pizzeria";
  }, []);

  const handlePurchaseComplete = (type) => {
    setPurchaseCompleted(true);
    setCurrentStep(0);
    setLastUpdated(new Date());
    setShowCloseButton(false);
    setOrderType(type); // Ensure this line is present
    setOrderStatus('Starting to process order');
  };

  const handleOrderStatusUpdate = (newStatus) => {
    console.log('New status received:', newStatus);
    setOrderStatus(newStatus.State);   
    setLastUpdated(new Date());
    
    const steps = orderType === 'delivery' ? deliverySteps : pickupSteps;
    let newStep = steps.indexOf(newStatus.State);

    // Some weird bug i haven't figured out yet so forcing these.
    if (newStatus.State === 'Order is ready for pickup' || newStatus.State === 'Sending out delivery') {
      newStep = 2;
    } else if (newStatus.State === 'Order was delivered') {
      newStep = 3;
    }
    if (newStep !== -1) {
      setCurrentStep(newStep);
    }

    if (newStatus.State === 'Order was delivered' || newStatus.State === 'Order is ready for pickup') {
      setShowCloseButton(true);
    }
  };

  const handleCloseProgress = () => {
    setPurchaseCompleted(false);
    setShowCloseButton(false);
  };

  return (
    <CartProvider>
      <Router>
        <div className="App">
          <Header />
          {purchaseCompleted && (
            <>
              <OrderProgressBar 
                currentStep={currentStep} 
                lastUpdated={lastUpdated}
                orderStatus={orderStatus}
                orderType={orderType}
              />
              {showCloseButton && (
                <button onClick={handleCloseProgress} className="close-progress-button">
                  Close Order Progress
                </button>
              )}
            </>
          )}
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/products" element={<ProductList />} />
            <Route path="/product/:id" element={<ProductDetail />} />
            <Route path="/cart" element={<Cart />} />
            <Route path="/profile" element={<Profile />} />
            <Route
              path="/checkout"
              element={
                <Checkout 
                  onPurchaseComplete={handlePurchaseComplete} 
                  isCheckoutDisabled={purchaseCompleted}
                  onOrderStatusUpdate={handleOrderStatusUpdate}
                />
              }
            />
          </Routes>
        </div>
      </Router>
    </CartProvider>
  );
}

export default App;