# 🚀 Quick Setup Guide for RideHub

Follow these steps to get RideHub running on your machine.

## ⚡ Quick Start (5 minutes)

### Step 1: Database Setup (2 minutes)

1. **Start MySQL Server**
   - Open MySQL Workbench or command line
   - Ensure MySQL is running

2. **Run Database Script**
   ```bash
   # Option A: Using MySQL Workbench
   # - Open MySQL Workbench
   # - File > Open SQL Script
   # - Select: server/database/init_database.sql
   # - Click Execute (⚡ icon)

   # Option B: Using Command Line
   mysql -u root -p < server/database/init_database.sql
   ```

3. **Verify Database**
   ```sql
   USE TransportBookingSystem;
   SHOW TABLES;
   -- You should see 8 tables
   ```

### Step 2: Backend Setup (1 minute)

1. **Navigate to server folder**
   ```bash
   cd server
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Create .env file**
   ```bash
   # Copy the example file
   cp .env.example .env
   
   # Edit .env and update your MySQL password
   # DB_PASSWORD=your_mysql_password
   ```

4. **Start backend**
   ```bash
   npm start
   ```
   
   ✅ You should see: "🚗 RideHub API Server Running"

### Step 3: Frontend Setup (2 minutes)

1. **Open a NEW terminal** (keep backend running)

2. **Navigate to root folder**
   ```bash
   cd ..  # Go back to root if you're in server/
   ```

3. **Install dependencies**
   ```bash
   npm install
   ```

4. **Create .env file**
   ```bash
   # Copy the example file
   cp .env.example .env
   
   # Edit .env and add your Gemini API key (optional for AI features)
   # VITE_API_KEY=your_gemini_api_key
   # VITE_API_URL=http://localhost:5000/api
   ```

5. **Start frontend**
   ```bash
   npm run dev
   ```

6. **Open browser**
   - Go to: http://localhost:5173
   - You should see the RideHub landing page! 🎉

## 🧪 Test the Application

### Test User Login
1. Click "Get Started" or "Sign In"
2. Use test account:
   - Email: `test@example.com`
   - Password: `test123` (or any password)
3. Try booking a ride:
   - From: Majestic
   - To: Lalbagh Botanical Garden

### Test Provider Login
1. Click "Become a Provider" or "Sign In"
2. Use test account:
   - Email: `ram@example.com`
   - Password: `test123` (or any password)
3. View and manage vehicles

## 🔧 Common Issues & Solutions

### Issue: "Database connection failed"
**Solution:**
- Check if MySQL is running
- Verify credentials in `server/.env`
- Test connection: `mysql -u root -p`

### Issue: "Port 5000 already in use"
**Solution:**
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID_NUMBER> /F

# Or change port in server/.env
PORT=5001
```

### Issue: "Cannot connect to backend"
**Solution:**
- Ensure backend is running (check terminal)
- Verify `VITE_API_URL` in frontend `.env`
- Check browser console for errors

### Issue: "npm install fails"
**Solution:**
```bash
# Clear cache and retry
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

## 📋 Checklist

Before starting, ensure you have:
- [ ] MySQL installed and running
- [ ] Node.js v18+ installed
- [ ] npm or yarn installed
- [ ] Two terminal windows open

## 🎯 What's Next?

After setup:
1. ✅ Create a new user account
2. ✅ Book your first ride
3. ✅ Try the AI trip suggester
4. ✅ Create a provider account
5. ✅ Add vehicles as a provider

## 💡 Pro Tips

1. **Keep both terminals open** - One for backend, one for frontend
2. **Check logs** - Both terminals show helpful error messages
3. **Use test data** - Pre-configured routes and fares are ready
4. **Browser DevTools** - F12 to see network requests and errors

## 🆘 Still Having Issues?

1. Check the main README.md for detailed documentation
2. Review the troubleshooting section
3. Verify all prerequisites are installed
4. Check both terminal outputs for errors

---

**Happy Coding! 🚗💨**
