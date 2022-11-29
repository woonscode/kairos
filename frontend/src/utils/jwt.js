import jwtDecode from 'jwt-decode';
import { verify, sign } from 'jsonwebtoken';
//
import axios from './axios';

// ----------------------------------------------------------------------

const isValidToken = async (accessToken) => {
  if (!accessToken) {
    return false;
  }

  let valid = false;

  // ----------------------------------------------------------------------

  const decoded = jwtDecode(accessToken);

  if(decoded.iss){
    console.log("useSSO");
    // use sso verification
    const decoded = jwtDecode(accessToken);
    const currentTime = Date.now() / 1000;
    valid = decoded.exp > currentTime;

  } else {
    await axios.post('/auth/jwt/verify/', {
      "token": accessToken
    }).then((res) => { if (res.status === 200){valid = true} }).catch((error) => {
      console.log(error);
    });
  }

  return valid

};

//  const handleTokenExpired = (exp) => {
//   let expiredTimer;

//   window.clearTimeout(expiredTimer);
//   const currentTime = Date.now();
//   const timeLeft = exp * 1000 - currentTime;
//   console.log(timeLeft);
//   expiredTimer = window.setTimeout(() => {
//     console.log('expired');
//     // You can do what ever you want here, like show a notification
//   }, timeLeft);
// };

// ----------------------------------------------------------------------

const setSession = (accessToken) => {
  if (accessToken) {
    localStorage.setItem('accessToken', accessToken);
    axios.defaults.headers.common.Authorization = `Bearer ${accessToken}`;
    // This function below will handle when token is expired
    // const { exp } = jwtDecode(accessToken);
    // handleTokenExpired(exp);
  } else {
    localStorage.removeItem('accessToken');
    delete axios.defaults.headers.common.Authorization;
  }
};

export { isValidToken, setSession, verify, sign };
