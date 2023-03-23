
DROP VIEW APP_STORE_APP_OVERVIEW;
DROP VIEW APP_STORE_USER_USAGE;
DROP VIEW USER_APP_DASHBOARD;
DROP VIEW USER_PAYMENT_DASHBOARD;
DROP VIEW DEV_APP_STATUS;
DROP VIEW REVENUE_DASHBOARD;


--------------------------------------------------------------------------------
CREATE VIEW APP_STORE_APP_OVERVIEW (CATEGORY_TYPE, OVERALL_RATING, CREATE_DATE, TOTAL_APPS) AS
SELECT CATEGORY_TYPE, 
        OVERALL_RATING,
        TRUNC(APP_CREATE_DT) CREATE_DATE, 
		COUNT(DISTINCT APP_ID) TOTAL_APPS
FROM APPLICATION A
JOIN APP_CATEGORY B ON A.CATEGORY_ID = B.CATEGORY_ID
GROUP BY CATEGORY_TYPE, OVERALL_RATING, TRUNC(APP_CREATE_DT)
;
--------------------------------------------------------------------------------
CREATE VIEW APP_STORE_USER_USAGE (CREATE_DATE, COUNTRY, TOTAL, COUNT_TYPE) AS
SELECT TRUNC(A.CREATED_AT) CREATE_DATE,
        B.COUNTRY,
		COUNT(DISTINCT A.USER_ID) TOTAL,
        'USERS' COUNT_TYPE
FROM USER_INFO A
JOIN PINCODE B ON A.USER_ZIP_CODE = B.ZIP_CODE
GROUP BY TRUNC(A.CREATED_AT), B.COUNTRY, 'USERS'
UNION ALL
SELECT TRUNC(C.CREATED_AT) CREATE_DATE,
        B.COUNTRY,
		COUNT(DISTINCT C.PROFILE_ID) TOTAL,
        'PROFILES' COUNT_TYPE
FROM USER_INFO A
JOIN PINCODE B ON A.USER_ZIP_CODE = B.ZIP_CODE
JOIN PROFILE C ON A.USER_ID = C.USER_ID
GROUP BY TRUNC(c.CREATED_AT), B.COUNTRY, 'PROFILES'
;
--------------------------------------------------------------------------------
CREATE VIEW USER_APP_DASHBOARD (USER_ID, TOTAL_PROFILES, TOTAL_APPS, TOTAL_SIZE, TOTAL_REVIEWS, TOTAL_SUBSCRIPTIONS) AS
SELECT A.USER_ID,
        COUNT(DISTINCT B.PROFILE_ID) TOTAL_PROFILES,
        COUNT(DISTINCT D.APP_ID) TOTAL_APPS,
        SUM(D.APP_SIZE) TOTAL_SIZE,
        COUNT(DISTINCT E.REVIEW_ID) TOTAL_REVIEWS,
        COUNT(DISTINCT F.SUBSCRIPTION_ID) TOTAL_SUBSCRIPTIONS
FROM USER_INFO A
JOIN PROFILE B ON A.USER_ID = B.USER_ID
JOIN USER_APP_CATALOGUE C ON B.PROFILE_ID = C.PROFILE_ID
JOIN APPLICATION D ON C.APP_ID = D.APP_ID
LEFT JOIN REVIEWS E ON A.USER_ID = E.USER_ID
LEFT JOIN SUBSCRIPTION F ON A.USER_ID = F.USER_ID
GROUP BY A.USER_ID
;
--------------------------------------------------------------------------------
CREATE VIEW USER_PAYMENT_DASHBOARD (USER_ID, SUBSCRIPTION_TYPE, TOTAL_SUBSCRIPTIONS, SUBSCRIPTION_AMOUT, NEXT_SUBSCRIPTION_END_DATE, MOST_RECENT_SUBSCRIPTION) AS
SELECT A.USER_ID,
        B.TYPE SUBSCRIPTION_TYPE,
        COUNT(DISTINCT B.SUBSCRIPTION_ID) TOTAL_SUBSCRIPTIONS,
        SUM(B.SUBSCRIPTION_AMOUNT) SUBSCRIPTION_AMOUT,
        MIN(CASE WHEN B.SUBSCRIPTION_END_DT >= SYSDATE THEN B.SUBSCRIPTION_END_DT ELSE NULL END) NEXT_SUBSCRIPTION_END_DATE,
        MAX(CASE WHEN B.SUBCRIPTION_START_DT <= SYSDATE THEN B.SUBCRIPTION_START_DT ELSE NULL END) MOST_RECENT_SUBSCRIPTION
FROM USER_INFO A
LEFT JOIN SUBSCRIPTION B ON A.USER_ID = B.USER_ID
GROUP BY A.USER_ID, B.TYPE
;
--------------------------------------------------------------------------------
CREATE VIEW DEV_APP_STATUS (DEVELOPER_NAME, APP_VERSION, SUBSCRIPTION_TYPE, TOTAL_USERS) AS
SELECT A.DEVELOPER_NAME,
        B.APP_VERSION,
        F.TYPE SUBSCRIPTION_TYPE,
        COUNT(DISTINCT D.USER_ID) TOTAL_USERS
FROM DEVELOPER A
JOIN APPLICATION B ON A.DEVELOPER_ID = B.DEVELOPER_ID
JOIN USER_APP_CATALOGUE C ON B.APP_ID = C.APP_ID
JOIN PROFILE D ON C.PROFILE_ID = D.PROFILE_ID
JOIN USER_INFO E ON D.USER_ID = E.USER_ID
LEFT JOIN SUBSCRIPTION F ON E.USER_ID = F.USER_ID
GROUP BY A.DEVELOPER_NAME, B.APP_VERSION, F.TYPE
;
--------------------------------------------------------------------------------
CREATE VIEW REVENUE_DASHBOARD (APP_ID, TOTAL_USERS, TOTAL_SUBSCRIPTION_AMT, TOTAL_AD_REVENUE, TOTAL_SUBSCRIPTIONS) AS
SELECT APPLICATION.APP_ID AS APP_ID, 
        APPLICATION.DOWNLOAD_COUNT AS TOTAL_USERS,
        SUM(SUBSCRIPTION.SUBSCRIPTION_AMOUNT) AS TOTAL_SUBSCRIPTION_AMT,
        SUM(ADVERTISEMENT.AD_COST) AS TOTAL_AD_REVENUE, 
        COUNT(SUBSCRIPTION.SUBSCRIPTION_ID) AS TOTAL_SUBSCRIPTIONS 
FROM APPLICATION
LEFT JOIN SUBSCRIPTION ON SUBSCRIPTION.APP_ID  = APPLICATION.APP_ID
LEFT JOIN ADVERTISEMENT ON ADVERTISEMENT.APP_ID = APPLICATION.APP_ID
GROUP BY APPLICATION.APP_ID,APPLICATION.DOWNLOAD_COUNT;
